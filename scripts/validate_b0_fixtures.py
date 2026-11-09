"""Validate draft fixture structure, references and UTF-16 span boundaries."""

import argparse
import json
from datetime import datetime
from pathlib import Path
from uuid import UUID


ROOT = Path(__file__).resolve().parents[1]


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def check_ids(rows, label):
    ids = [row["id"] for row in rows]
    require(len(set(ids)) == len(ids), f"{label}: duplicate ID")
    for value in ids:
        require(str(UUID(value)) == value, f"{label}: invalid UUID")
    return set(ids)


def validate(directory):
    grammar = read_json(directory / "grammar.draft.json")
    questions = read_json(directory / "questions.draft.json")
    for name, document in [("grammar", grammar), ("questions", questions)]:
        require(document["status"] == "pending_review", f"{name}: expected draft status")
        require(document["reviewed_by"] is None, f"{name}: unexpected reviewer")
        require(document["reviewed_at"] is None, f"{name}: unexpected approval date")
    points = grammar["grammar_points"]
    require(len(points) == 12, "B0 requires 12 grammar points")
    ids = check_ids(points, "grammar")
    by_id = {point["id"]: point for point in points}
    for original in read_json(ROOT / "assets/data/grammar.json"):
        require(by_id.get(original["id"]) == original, "Legacy grammar was modified")
    fields = ["pattern", "level", "category", "meaning_vi", "formula", "usage_vi"]
    for point in points:
        require(point["level"] in ("N5", "N4"), "Unknown JLPT level")
        require(all(isinstance(point[key], str) and point[key].strip() for key in fields), "Empty grammar field")
        require(bool(point["grammar_examples"]), "Missing example")
        for example in point["grammar_examples"]:
            require(bool(example["sentence_ja"].strip() and example["translation_vi"].strip()), "Empty example")
    items = questions["questions"]
    require(len(items) == 24, "B0 requires 24 questions")
    check_ids(items, "questions")
    coverage = {value: [] for value in ids}
    for item in items:
        require(item["grammar_id"] in ids, "Question references unknown grammar")
        coverage[item["grammar_id"]].append(item["type"])
        require(item["content_version"] == 1, "Unexpected content version")
        require(bool(item["prompt"].strip() and item["explanation_vi"].strip()), "Empty question content")
        if item["type"] == "mcq":
            choices = item["options"]
            require(len(choices) == 4 and len(set(choices)) == 4, "MCQ needs four distinct choices")
            require(all(isinstance(x, str) and x.strip() for x in choices), "Empty MCQ choice")
            require(type(item["correct_option_index"]) is int and 0 <= item["correct_option_index"] < 4, "Invalid MCQ answer index")
        elif item["type"] == "cloze":
            require(item["prompt"].count("（　）") == 1, "Cloze needs one blank")
            require(item["normalization"] == "trim_only", "Unexpected cloze normalization")
            answers = item["accepted_answers"]
            require(bool(answers) and all(isinstance(x, str) and x.strip() == x and x for x in answers), "Invalid cloze answers")
        else:
            raise ValueError("Unknown question type")
    require(all(sorted(types) == ["cloze", "mcq"] for types in coverage.values()), "Each grammar needs one MCQ and one cloze")
    cases = read_json(directory / "analysis.cases.json")["cases"]
    require(len({case["name"] for case in cases}) == len(cases), "Duplicate analysis case")
    expected = {"success_unicode_span", "no_match", "unauthenticated", "quota_exceeded", "invalid_input", "timeout", "unavailable", "invalid_output", "duplicate_processing", "request_conflict"}
    require({case["name"] for case in cases} == expected, "Missing analysis case")
    for case in cases:
        request, response = case["request"], case["response"]
        require(request["request_id"] == response["request_id"], "Response ID mismatch")
        UUID(request["request_id"])
        if case["expected_http"] == 200:
            require(type(response["remaining_quota"]) is int and response["remaining_quota"] >= 0, "Invalid quota")
            for match in response["matches"]:
                require(match["grammar_id"] in ids, "Success contains unknown grammar ID")
                if "span" in match:
                    span = match["span"]
                    encoded = request["text"].encode("utf-16-le")
                    start, end = span["start_utf16"], span["end_utf16"]
                    require(type(start) is int and type(end) is int and 0 <= start < end <= len(encoded) // 2, "Invalid UTF-16 offsets")
                    require(encoded[start * 2:end * 2].decode("utf-16-le") == span["text"], "Span does not match request")
        elif case["expected_http"] == 202:
            require(response["status"] == "processing" and response["retry_after_ms"] > 0, "Invalid processing response")
        else:
            require(response["error"]["code"] == case["name"], "Wrong error code")
            require(type(response["error"]["retryable"]) is bool, "Invalid retry flag")
    sync = read_json(directory / "sync.cases.json")
    records = sync["record_cases"]
    require({case["name"] for case in records} == {"stale_edit", "delete_then_stale_edit", "timeout_after_commit", "explicit_conflict_resolution"}, "Missing sync fixture")
    for case in records:
        require(len(case["operations"]) == len(case["expected_statuses"]), "Missing sync expectation")
        for operation in case["operations"]:
            UUID(operation["operation_id"])
            require(type(operation["base_revision"]) is int and operation["base_revision"] >= 0, "Invalid base revision")
        expected_revision = case["initial"]["revision"] + case["expected_statuses"].count("applied")
        require(case["expected_final"]["revision"] == expected_revision, "Inconsistent expected revision")
        operation_ids = {operation["operation_id"] for operation in case["operations"]}
        require(set(case["preserve_pending_operations"]) <= operation_ids, "Unknown pending operation")
    review = sync["review_case"]
    attempts = review["attempts"]
    check_ids(attempts, "attempts")
    question_ids = {item["id"] for item in items}
    for attempt in attempts:
        require(attempt["question_id"] in question_ids, "Unknown attempt question")
        UUID(attempt["session_id"])
        datetime.fromisoformat(attempt["attempted_at"])
        datetime.fromisoformat(attempt["server_received_at"])
    ordered = sorted(attempts, key=lambda attempt: (datetime.fromisoformat(attempt["server_received_at"]), attempt["id"]))
    require([attempt["id"] for attempt in ordered] == review["expected_order"], "Review expectation ignores receipt ordering")
    quota = sync["quota_case"]
    require(quota["daily_limit"] - quota["used"] == quota["remaining_slots"] == quota["expected_reserved_count"], "Inconsistent quota fixture")
    require(len(quota["request_ids"]) - quota["expected_reserved_count"] == quota["expected_quota_exceeded_count"], "Inconsistent concurrent quota fixture")
    return len(points), len(items), len(cases), len(records)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fixtures-dir", type=Path, default=ROOT / "documents/development/fixtures/b0")
    args = parser.parse_args()
    try:
        counts = validate(args.fixtures_dir)
    except (ValueError, KeyError, TypeError, OSError) as error:
        parser.exit(1, f"FAIL: {error}\n")
    print(f"PASS: {counts[0]} draft grammar points, {counts[1]} questions, {counts[2]} analysis cases, {counts[3]} sync cases + review/quota fixtures; no content approval or live backend verification implied.")


if __name__ == "__main__":
    main()

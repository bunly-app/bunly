"""Generate synchronized draft N5/N4 curriculum assets and local seed SQL.

Content status: AI-authored curriculum drafts built atop B0 fixtures;
requires human pedagogical & JLPT review before final release sign-off.
"""

from __future__ import annotations

import json
from pathlib import Path
from uuid import UUID

ROOT = Path(__file__).resolve().parents[1]
B0_DIR = ROOT / "documents/development/fixtures/b0"

ALLOWED_CATEGORIES = {
    "experience",
    "desire",
    "aspect",
    "permission",
    "prohibition",
    "obligation",
    "intention",
    "simultaneous",
    "comparison",
    "ability",
    "sequence",
    "particles",
    "existence",
    "tense_negation",
    "adjectives",
    "request_suggestion",
    "reason_contrast",
    "condition",
    "quoting_noun",
    "giving_receiving",
    "voice_politeness",
}

# Each tuple:
# (
#   index (13..90), level ('N5'|'N4'), category, pattern, meaning_vi, formula, usage_vi,
#   [(ex1_ja, ex1_vi), (ex2_ja, ex2_vi)],
#   mcq: (prompt, [opt0, opt1, opt2, opt3], correct_index, explanation_vi),
#   cloze: (prompt_with_blank, [accepted...], explanation_vi)
# )
NEW_ENTRIES = [
    # --- N5 (0013..0051 = 39 entries, total N5 = 45) ---
    (
        13, "N5", "particles", "〜は〜です", "A là B (khẳng định lịch sự)",
        "Danh từ A + は + Danh từ B + です",
        "Giới thiệu chủ đề A và khẳng định tính chất hoặc danh phận B một cách lịch sự.",
        [("私は学生です。", "Tôi là sinh viên."), ("明日は日曜日です。", "Ngày mai là Chủ nhật.")],
        ("Điền trợ từ thích hợp: 私（　）大学生です。", ["は", "を", "に", "へ"], 0, "Trợ từ は đánh dấu chủ đề của câu."),
        ("山田さんは会社員（　）。", ["です", "ます"], "Danh từ kết hợp です ở cuối câu khẳng định lịch sự."),
    ),
    (
        14, "N5", "particles", "〜ではありません", "Không phải là ~ (phủ định lịch sự)",
        "Danh từ / Tính từ な + ではありません（じゃありません）",
        "Phủ định danh từ hoặc tính từ đuôi な trong văn nói/viết lịch sự.",
        [("私は先生ではありません。", "Tôi không phải là giáo viên."), ("ここは図書館ではありません。", "Đây không phải là thư viện.")],
        ("Chọn dạng phủ định đúng: あの人は田中さん（　）。", ["ではありません", "ではありませんか", "くないです", "ます"], 0, "Danh từ phủ định lịch sự dùng ではありません."),
        ("明日は休み（　）ありません。", ["では", "じゃ"], "Cụm cố định ではありません dùng để phủ định danh từ."),
    ),
    (
        15, "N5", "particles", "〜か", "Câu hỏi lịch sự (có phải ~ không?)",
        "Câu lịch sự (〜です / 〜ます) + か",
        "Đặt か ở cuối câu để chuyển thành câu nghi vấn lịch sự, không cần thêm dấu hỏi chấm khi viết chuẩn.",
        [("お名前は何ですか。", "Tên bạn là gì vậy?"), ("毎朝コーヒーを飲みますか。", "Mỗi sáng bạn có uống cà phê không?")],
        ("Chọn trợ từ cuối câu để đặt câu hỏi: あなたは留学生です（　）。", ["よ", "か", "ね", "が"], 1, "Trợ từ か ở cuối câu tạo câu nghi vấn lịch sự."),
        ("これは誰の傘です（　）。", ["か"], "Đặt か ở cuối câu để hỏi."),
    ),
    (
        16, "N5", "particles", "〜の〜", "Của ~ / bổ nghĩa giữa hai danh từ",
        "Danh từ 1 + の + Danh từ 2",
        "Nối hai danh từ để biểu thị sở hữu, nguồn gốc hoặc nội dung của danh từ đứng sau.",
        [("これは私の本です。", "Đây là sách của tôi."), ("日本語の先生と話しました。", "Tôi đã nói chuyện với thầy giáo tiếng Nhật.")],
        ("Điền trợ từ nối hai danh từ: これは日本（　）車です。", ["を", "に", "の", "で"], 2, "Trợ từ の nối hai danh từ để chỉ nguồn gốc/sở hữu."),
        ("兄（　）部屋は二階にあります。", ["の"], "の biểu thị quan hệ sở hữu giữa 兄 và 部屋."),
    ),
    (
        17, "N5", "particles", "〜も", "Cũng ~ (thêm đối tượng tương đồng)",
        "Danh từ + も",
        "Thay cho は hoặc が khi muốn diễn tả đối tượng khác cũng có trạng thái hay hành động tương tự.",
        [("私も学生です。", "Tôi cũng là sinh viên."), ("昨日も雨が降りました。", "Hôm qua trời cũng mưa.")],
        ("Chọn trợ từ mang nghĩa 'cũng': リンさんはベトナム人です。ナムさん（　）ベトナム人です。", ["は", "も", "を", "へ"], 1, "Dùng も thay は khi khẳng định điều tương tự cho đối tượng tiếp theo."),
        ("コーヒーを飲みます。紅茶（　）飲みます。", ["も"], "も mang nghĩa 'cũng' khi liệt kê thêm hành động giống nhau."),
    ),
    (
        18, "N5", "particles", "〜を", "Tân ngữ trực tiếp của hành động",
        "Danh từ + を + Ngoại động từ",
        "Chỉ đối tượng chịu tác động trực tiếp của hành động.",
        [("朝ご飯を食べます。", "Tôi ăn bữa sáng."), ("毎日日本語を勉強します。", "Mỗi ngày tôi học tiếng Nhật.")],
        ("Điền trợ từ chỉ tân ngữ: 図書館で本（　）読みます。", ["が", "で", "を", "と"], 2, "Động từ đọc (読む) đi với tân ngữ qua trợ từ を."),
        ("毎晩、音楽（　）聞きます。", ["を"], "を đánh dấu đối tượng trực tiếp của động từ 聞きます."),
    ),
    (
        19, "N5", "particles", "〜に（時間）", "Vào lúc ~ (mốc thời gian cụ thể)",
        "Danh từ thời gian có số cụ thể + に + Động từ",
        "Dùng cho giờ, ngày, tháng, năm, thứ; không dùng sau 今日, 明日, 毎日.",
        [("毎朝六時に起きます。", "Mỗi sáng tôi dậy lúc 6 giờ."), ("十月に日本へ行きます。", "Tháng 10 tôi sẽ đi Nhật.")],
        ("Chọn câu dùng đúng trợ từ chỉ thời gian: 私は（　）寝ます。", ["毎日十一時に", "今日に十一時", "明日に", "毎晩に"], 0, "Thời gian có con số cụ thể như 十一時 dùng に, còn 毎日 không đi kèm に."),
        ("日曜日の朝九時（　）友達に会います。", ["に"], "Giờ cụ thể (九時) cần trợ từ に."),
    ),
    (
        20, "N5", "particles", "〜に・へ（方向）", "Đi về hướng / tới địa điểm ~",
        "Địa điểm + に / へ + 行きます・来ます・帰ります",
        "Biểu thị điểm đến hoặc phương hướng với các động từ di chuyển.",
        [("来週、東京へ行きます。", "Tuần sau tôi sẽ đi Tokyo."), ("五時に家へ帰ります。", "5 giờ tôi về nhà.")],
        ("Chọn trợ từ đi với động từ di chuyển: 夏休みに京都（　）行きます。", ["を", "で", "へ", "から"], 2, "Với động từ đi/đến/về dùng へ hoặc に sau địa điểm."),
        ("午後、大学（　）来ます。", ["へ", "に"], "Địa điểm đích của động từ 来ます dùng へ hoặc に."),
    ),
    (
        21, "N5", "particles", "〜で（場所）", "Tại địa điểm ~ (nơi diễn ra hành động)",
        "Địa điểm + で + Hành động",
        "Chỉ địa điểm nơi một hành động cụ thể diễn ra; khác với に dùng cho tồn tại hoặc đích đến.",
        [("食堂で昼ご飯を食べます。", "Tôi ăn trưa ở nhà ăn."), ("駅で新聞を買いました。", "Tôi đã mua báo ở nhà ga.")],
        ("Điền trợ từ chỉ nơi diễn ra hành động: スーパー（　）りんごを買います。", ["へ", "に", "を", "で"], 3, "Nơi diễn ra hành động mua sắm dùng trợ từ で."),
        ("部屋の机（　）宿題をします。", ["で"], "Hành động làm bài tập xảy ra tại địa điểm dùng で."),
    ),
    (
        22, "N5", "particles", "〜で（手段・道具）", "Bằng phương tiện / công cụ / ngôn ngữ ~",
        "Phương tiện / Công cụ / Ngôn ngữ + で + Động từ",
        "Nêu cách thức, phương tiện đi lại, dụng cụ hoặc ngôn ngữ thực hiện hành động.",
        [("電車で会社へ行きます。", "Tôi đi đến công ty bằng tàu điện."), ("はしでご飯を食べます。", "Tôi ăn cơm bằng đũa.")],
        ("Chọn trợ từ chỉ phương tiện: バス（　）空港まで行きました。", ["で", "に", "へ", "を"], 0, "Phương tiện di chuyển dùng trợ từ で."),
        ("日本語（　）手紙を書きます。", ["で"], "Ngôn ngữ dùng để viết nói đi với trợ từ で."),
    ),
    (
        23, "N5", "particles", "〜と（共同）", "Cùng với ai / và (liệt kê đầy đủ)",
        "Người + と + Hành động / Danh từ A + と + Danh từ B",
        "Diễn tả đối tượng cùng thực hiện hành động, hoặc nối trọn vẹn các danh từ.",
        [("友達と映画を見ました。", "Tôi đã xem phim cùng bạn."), ("机の上に本とペンがあります。", "Trên bàn có sách và bút.")],
        ("Điền trợ từ nghĩa 'cùng với': 週末に姉（　）買い物に行きます。", ["や", "と", "へ", "に"], 1, "Thực hiện hành động cùng người khác dùng trợ từ と."),
        ("家族（　）旅行に行きました。", ["と"], "Đi cùng gia đình dùng trợ từ と."),
    ),
    (
        24, "N5", "particles", "〜から〜まで", "Từ ~ đến ~ (thời gian / địa điểm)",
        "Mốc A + から + Mốc B + まで",
        "Xác định điểm bắt đầu và điểm kết thúc của khoảng thời gian hoặc quãng đường.",
        [("授業は九時から十一時までです。", "Tiết học từ 9 giờ đến 11 giờ."), ("うちから駅まで歩いて十分です。", "Từ nhà đến ga đi bộ mất 10 phút.")],
        ("Chọn cặp trợ từ phù hợp: 図書館は朝八時（　）夕方六時（　）開いています。", ["まで・から", "に・で", "から・まで", "へ・まで"], 2, "Mốc bắt đầu dùng から, mốc kết thúc dùng まで."),
        ("月曜日から金曜日（　）働きます。", ["まで"], "Điểm kết thúc thời gian làm việc dùng まで."),
    ),
    (
        25, "N5", "particles", "〜や〜など", "A, B và những thứ khác (liệt kê tiêu biểu)",
        "Danh từ A + や + Danh từ B（+ など）",
        "Liệt kê vài ví dụ tiêu biểu trong nhóm nhiều sự vật, hàm ý còn nhiều thứ khác nữa.",
        [("かばんの中にノートや辞書などが入っています。", "Trong cặp có vở, từ điển v.v."), ("休みはテニスや水泳をします。", "Ngày nghỉ tôi chơi tennis, bơi lội...")],
        ("Chọn trợ từ liệt kê không đầy đủ: 冷蔵庫に卵（　）牛乳などがあります。", ["と", "も", "の", "や"], 3, "Khi liệt kê đại diện kèm など dùng や."),
        ("机の上にペン（　）ノートなどがあります。", ["や"], "Liệt kê không hết các ví dụ tiêu biểu dùng や kèm など."),
    ),
    (
        26, "N5", "existence", "〜に〜がある", "Có (đồ vật / sự kiện) ở ~",
        "Địa điểm + に + Đồ vật / Sự việc + が + あります",
        "Dùng động từ あります để nói về sự tồn tại của vật vô tri, cây cối hoặc sự kiện.",
        [("教室にテレビがあります。", "Trong lớp học có ti vi."), ("明日、会議があります。", "Ngày mai có cuộc họp.")],
        ("Chọn động từ tồn tại đúng cho đồ vật: 公園の横に郵便局が（　）。", ["あります", "います", "します", "なります"], 0, "Địa điểm/đồ vật vô tri dùng あります."),
        ("棚の上に写真（　）あります。", ["が"], "Chủ thể tồn tại trong mẫu ～にあります dùng trợ từ が."),
    ),
    (
        27, "N5", "existence", "〜に〜がいる", "Có (người / động vật) ở ~",
        "Địa điểm + に + Người / Động vật + が + います",
        "Dùng động từ います để diễn tả người hoặc động vật đang có mặt tại nơi nào đó.",
        [("庭に猫がいます。", "Ở ngoài sân có con mèo."), ("事務所に誰もいません。", "Trong văn phòng không có ai cả.")],
        ("Chọn động từ đúng cho người/động vật: 教室に新しい学生が（　）。", ["あります", "います", "です", "します"], 1, "Người và động vật dùng います."),
        ("あそこに男の子（　）います。", ["が"], "Danh từ chỉ người/động vật trước います đi với が."),
    ),
    (
        28, "N5", "tense_negation", "〜ます・〜ません", "Thể lịch sự hiện tại & phủ định",
        "Động từ gốc ます + ます（khẳng định）/ ません（phủ định）",
        "Diễn tả thói quen hàng ngày hoặc dự định trong tương lai ở sắc thái lịch sự.",
        [("毎朝七時に朝ご飯を食べます。", "Mỗi sáng tôi ăn sáng lúc 7 giờ."), ("お酒は飲みません。", "Tôi không uống rượu.")],
        ("Chọn dạng phủ định hiện tại lịch sự của 行く: 今夜は出掛け（　）。", ["ます", "ました", "ません", "ませんでした"], 2, "Phủ định hiện tại lịch sự dùng đuôi ません."),
        ("私は肉を食べ（　）。野菜だけ食べます。", ["ません"], "Ngữ cảnh câu sau nêu rõ phủ định hiện tại -> ません."),
    ),
    (
        29, "N5", "tense_negation", "〜ました・〜ませんでした", "Thể lịch sự quá khứ & phủ định quá khứ",
        "Động từ gốc ます + ました / ませんでした",
        "Diễn tả hành động đã hoàn thành hoặc không xảy ra trong quá khứ.",
        [("昨日、図書館で勉強しました。", "Hôm qua tôi đã học ở thư viện."), ("今朝、テレビを見ませんでした。", "Sáng nay tôi đã không xem ti vi.")],
        ("Điền đuôi quá khứ phù hợp: 昨日の夜、十時に（　）。", ["寝ます", "寝ません", "寝ませんで", "寝ました"], 3, "Có mốc quá khứ 昨日の夜 nên chia động từ ở ました."),
        ("先週は忙しかったので、どこへも行き（　）。", ["ませんでした"], "Phủ định trong quá khứ dùng ませんでした."),
    ),
    (
        30, "N5", "tense_negation", "〜ていない", "Chưa làm ~ / trạng thái chưa diễn ra",
        "Động từ thể て + いない（います・いません）",
        "Khi đi với まだ (vẫn chưa), diễn tả việc tính đến hiện tại vẫn chưa xảy ra hoặc chưa xong.",
        [("まだ昼ご飯を食べていません。", "Tôi vẫn chưa ăn trưa."), ("田中さんはまだ来ていないようです。", "Anh Tanaka hình như vẫn chưa đến.")],
        ("Chọn dạng diễn tả 'vẫn chưa làm': まだレポートを（　）。", ["書いていません", "書きました", "書きます", "書きません"], 0, "Với trạng từ まだ, dùng 〜ていません để chỉ việc chưa hoàn thành."),
        ("その映画はまだ（　）いません。", ["見て"], "Thể て của 見る là 見て kết hợp いません."),
    ),
    (
        31, "N5", "tense_negation", "〜た・〜なかった", "Thể thông thường quá khứ",
        "Động từ thể た / Động từ thể ない bỏ い + かった",
        "Dùng khi nói chuyện thân mật hoặc trước danh từ/liên từ nối câu trong quá khứ.",
        [("昨日、友達と会った。", "Hôm qua tôi đã gặp bạn."), ("朝ご飯は食べなかった。", "Tôi đã không ăn sáng.")],
        ("Chọn thể thông thường quá khứ phủ định của 行く: 先週は学校へ（　）。", ["行かない", "行かなかった", "行った", "行きます"], 1, "Quá khứ phủ định thể thông thường là 行かなかった."),
        ("昨日のテストはあまり難しく（　）。", ["なかった"], "Tính từ い phủ định quá khứ đổi thành 〜くなかった."),
    ),
    (
        32, "N5", "adjectives", "い形容詞（〜い・〜くない）", "Tính từ đuôi い khẳng định & phủ định",
        "Gốc tính từ い + い（khẳng định）/ + くない（phủ định）",
        "Biểu thị tính chất sự vật; lưu ý ngoại lệ いい chia phủ định thành よくない.",
        [("この部屋は広いです。", "Căn phòng này rộng."), ("今日のテストは難しくないです。", "Bài kiểm tra hôm nay không khó.")],
        ("Chọn phủ định đúng của いい: 今日は天気が（　）です。", ["いくない", "いいくない", "よくない", "よいない"], 2, "いい là ngoại lệ, khi chia phủ định đổi gốc thành よくない."),
        ("このスープはあまり熱（　）です。", ["くない"], "Phủ định tính từ đuôi い bỏ い cộng くない."),
    ),
    (
        33, "N5", "adjectives", "な形容詞（〜だ・〜ではない）", "Tính từ đuôi な (bổ nghĩa & vị ngữ)",
        "Vị ngữ: Tính từ な + です / ではありません; Bổ nghĩa: Tính từ な + な + Danh từ",
        "Mô tả tính chất; khi đứng trước danh từ phải giữ chữ な.",
        [("京都は静かな町です。", "Kyoto là một thành phố yên tĩnh."), ("この駅はあまり賑やかではありません。", "Nhà ga này không náo nhiệt lắm.")],
        ("Chọn cụm đúng trước danh từ: 彼はとても（　）人です。", ["親切", "親切い", "親切に", "親切な"], 3, "Tính từ đuôi な (親切) đứng trước danh từ bắt buộc thêm な."),
        ("この公園はとても静か（　）ですね。", ["です", "だ"], "Làm vị ngữ cuối câu lịch sự chỉ dùng です, không giữ な."),
    ),
    (
        34, "N5", "adjectives", "〜くなる・〜になる", "Trở nên / biến đổi trạng thái",
        "Tính từ い bỏ い + くなる / Tính từ な・Danh từ + になる",
        "Diễn tả sự thay đổi tự nhiên hoặc kết quả theo thời gian.",
        [("だんだん暖かくなりました。", "Trời dần trở nên ấm áp."), ("妹は来年二十歳になります。", "Năm sau em gái tôi sẽ bước sang tuổi 20.")],
        ("Chọn dạng biến đổi đúng: たくさん練習して、日本語が上手（　）。", ["になりました", "くなりました", "をしました", "があります"], 0, "上手 là tính từ đuôi な nên đi với になる."),
        ("夜になって、急に寒（　）なりました。", ["く"], "Tính từ đuôi い (寒い) bỏ い cộng くなる."),
    ),
    (
        35, "N5", "adjectives", "〜くて・〜で", "Nối hai tính từ / danh từ mang nghĩa liệt kê",
        "Tính từ い bỏ い + くて / Tính từ な・Danh từ + で",
        "Nối các đặc điểm cùng chiều hoặc trung tính trong một câu mô tả.",
        [("この店は安くておいしいです。", "Quán này vừa rẻ vừa ngon."), ("ミラーさんは親切でハンサムです。", "Anh Miller vừa tốt bụng vừa đẹp trai.")],
        ("Chọn cách nối đúng giữa 広い và 明るい: この教室は（　）明るいです。", ["広いで", "広くて", "広いと", "広いな"], 1, "Tính từ đuôi い nối tiếp nhau đổi い thành くて."),
        ("この町は静か（　）、とても住みやすいです。", ["で"], "Tính từ đuôi な nối sang vế sau bằng で."),
    ),
    (
        36, "N5", "adjectives", "〜が好きだ・〜が上手だ", "Thích / giỏi / ghét / kém ~ (với trợ từ が)",
        "Danh từ + が + 好き・嫌い・上手・下手 + です",
        "Đối tượng của cảm xúc, sở thích và năng lực đi với trợ từ が chứ không dùng を.",
        [("私は日本料理が好きです。", "Tôi thích món ăn Nhật."), ("山本さんは歌が上手ですね。", "Bạn Yamamoto hát hay quá nhỉ.")],
        ("Điền trợ từ thích hợp: 弟はサッカー（　）とても上手です。", ["を", "で", "が", "に"], 2, "Trước tính từ chỉ năng lực/sở thích như 上手 dùng trợ từ が."),
        ("私は辛い料理（　）あまり好きではありません。", ["が"], "Đối tượng của 好き đi kèm trợ từ が."),
    ),
    (
        37, "N5", "request_suggestion", "〜てください", "Xin hãy làm ~ (yêu cầu lịch sự)",
        "Động từ thể て + ください",
        "Dùng để nhờ vả, hướng dẫn hoặc mời ai đó làm việc gì một cách lịch sự.",
        [("ここに名前を書いてください。", "Xin hãy viết tên vào đây."), ("すみませんが、ちょっと待ってください。", "Xin lỗi, vui lòng đợi một chút.")],
        ("Chọn thể đúng trước ください: もう一度ゆっくり（　）ください。", ["言う", "言った", "言います", "言って"], 3, "Mẫu đề nghị dùng Động từ thể て + ください (言う -> 言って)."),
        ("ドアを（　）ください。とても暑いですから。", ["開けて", "あけて"], "開ける đổi sang thể て là 開けて."),
    ),
    (
        38, "N5", "request_suggestion", "〜ないでください", "Xin đừng làm ~ (nhắc nhở lịch sự)",
        "Động từ thể ない + で + ください",
        "Yêu cầu hoặc khuyên người khác đừng thực hiện một hành động nào đó.",
        [("ここで写真を撮らないでください。", "Xin đừng chụp ảnh ở đây."), ("大切なことですから、忘れないでください。", "Vì là việc quan trọng nên đừng quên nhé.")],
        ("Chọn mẫu khuyên 'đừng làm': 図書館では大きい声で（　）。", ["話さないでください", "話してください", "話すください", "話さないください"], 0, "Cấu trúc 'xin đừng' là Vない + でください."),
        ("夜遅くまで起き（　）ください。", ["ないで"], "Phủ định thể ない trước でください."),
    ),
    (
        39, "N5", "request_suggestion", "〜ませんか", "Cùng làm ~ không? (mời rủ lịch sự)",
        "Động từ gốc ます + ませんか",
        "Mời người nghe cùng tham gia hành động, tôn trọng lựa chọn từ chối của đối phương.",
        [("いっしょに昼ご飯を食べませんか。", "Chúng ta cùng ăn trưa nhé?"), ("土曜日、映画を見に行きませんか。", "Thứ Bảy đi xem phim cùng không?")],
        ("Chọn câu mời rủ lịch sự: 明日、いっしょにテニスを（　）。", ["しませんでした", "しませんか", "しています", "したかった"], 1, "〜ませんか là lời mời lịch sự 'cùng làm nhé?'."),
        ("ちょっと喫茶店でコーヒーを飲み（　）か。", ["ません"], "Cấu trúc mời gọi lịch sự Vません + か."),
    ),
    (
        40, "N5", "request_suggestion", "〜ましょう", "Hãy cùng làm ~ nhé (đề xuất hào hứng)",
        "Động từ gốc ます + ましょう",
        "Đưa ra đề nghị cùng làm ngay hoặc đáp lại đồng ý lời mời của người khác.",
        [("そろそろ帰りましょう。", "Chúng ta về thôi nào."), ("ちょっと休みましょう。", "Nghỉ một chút nhé.")],
        ("Chọn câu đáp đồng ý phù hợp cho lời mời '飲みませんか': ええ、（　）。", ["飲みません", "飲みました", "飲みましょう", "飲んで"], 2, "Đáp lại đồng thuận lời rủ thường dùng Vましょう."),
        ("授業が始まりますから、静かにし（　）。", ["ましょう"], "Đề nghị mọi người cùng hành động dùng ましょう."),
    ),
    (
        41, "N5", "request_suggestion", "〜ましょうか", "Để tôi làm giúp ~ nhé? / Chúng ta làm ~ nhé?",
        "Động từ gốc ます + ましょうか",
        "Đề nghị giúp đỡ người nghe một việc gì đó hoặc gợi ý cùng làm.",
        [("荷物を持ちましょうか。", "Để tôi xách hành lý giúp bạn nhé?"), ("駅まで迎えに行きましょうか。", "Tôi ra ga đón bạn nhé?")],
        ("Chọn câu đề nghị giúp đỡ: 雨が降ってきましたね。傘を（　）。", ["貸しましょう", "借りますか", "貸しません", "貸しましょうか"], 3, "Vましょうか thể hiện ý ngỏ lời giúp đối phương."),
        ("暑いですから、窓を開け（　）か。", ["ましょう"], "Ngỏ ý mở cửa sổ giúp đối phương: 開けましょうか."),
    ),
    (
        42, "N5", "request_suggestion", "〜たほうがいい", "Nên làm / không nên làm ~",
        "Động từ thể た / Động từ thể ない + ほうがいいです",
        "Đưa ra lời khuyên trực tiếp cho người nghe nên hoặc không nên làm việc gì.",
        [("熱があるときは、早く寝たほうがいいです。", "Khi bị sốt thì bạn nên đi ngủ sớm."), ("夜は甘いものを食べないほうがいいです。", "Buổi tối thì không nên ăn đồ ngọt.")],
        ("Chọn thể đúng để khuyên 'nên đi khám': 薬を（　）ほうがいいですよ。", ["飲んだ", "飲む", "飲んで", "飲みます"], 0, "Khuyên NÊN làm dùng Động từ thể た + ほうがいい."),
        ("疲れているなら、今日は無理を（　）ほうがいいです。", ["しない"], "Khuyên KHÔNG nên dùng thể ない + ほうがいい."),
    ),
    (
        43, "N5", "reason_contrast", "〜から（理由）", "Vì ~ nên ~ (nêu lý do chủ quan)",
        "Mệnh đề lý do + から、Mệnh đề kết quả",
        "Trình bày nguyên nhân rồi dẫn tới kết luận, phán đoán hoặc yêu cầu của người nói.",
        [("時間がありませんから、急ぎましょう。", "Vì không có thời gian nên hãy nhanh lên."), ("今日は寒いから、コートを着ます。", "Hôm nay lạnh nên tôi mặc áo khoác.")],
        ("Chọn liên từ chỉ lý do phù hợp: 風邪をひいた（　）、今日は会社を休みます。", ["のでが", "から", "ても", "のに"], 1, "から đặt sau mệnh đề nguyên nhân mang nghĩa 'vì'."),
        ("漢字が難しい（　）、毎日練習しています。", ["から"], "Mệnh đề đầu giải thích lý do cho hành động sau."),
    ),
    (
        44, "N5", "reason_contrast", "〜が・〜けれども", "Nhưng mà ~ (nối hai ý tương phản nhẹ)",
        "Mệnh đề A + が / けれども、Mệnh đề B",
        "Nối hai mệnh đề trái ngược hoặc dùng để mở đầu nhẹ nhàng khi nhờ vả.",
        [("日本の生活は楽しいですが、少し寂しいです。", "Cuộc sống ở Nhật vui nhưng hơi cô đơn một chút."), ("すみませんが、塩を取ってください。", "Xin lỗi, vui lòng lấy giúp tôi lọ muối.")],
        ("Điền từ nối tương phản: 部屋は狭い（　）、とてもきれいです。", ["から", "より", "が", "て"], 2, "Hai tính chất trái chiều 'hẹp' và 'đẹp' nối bằng が / けれども."),
        ("日本語は難しいです（　）、おもしろいです。", ["が", "けれども"], "Liên từ が hoặc けれども nối hai nhận xét tương phản."),
    ),
    (
        45, "N5", "reason_contrast", "〜て・〜で（順接）", "Làm A rồi làm B (liệt kê hành động nối tiếp)",
        "Động từ 1 thể て + Động từ 2 thể て + Động từ chính",
        "Sắp xếp nhiều hành động theo trình tự thời gian liên tiếp trong một câu.",
        [("朝起きて、顔を洗って、学校へ行きます。", "Sáng dậy, rửa mặt rồi tôi đi học."), ("デパートへ行って、買い物をしました。", "Tôi đã đến trung tâm thương mại và mua sắm.")],
        ("Chọn thể nối hai hành động liên tiếp: 電車に（　）、会社へ行きます。", ["乗る", "乗った", "乗ります", "乗って"], 3, "Động từ 乗る nối tiếp sang hành động sau đổi sang thể て là 乗って."),
        ("家に帰っ（　）、すぐシャワーを浴びました。", ["て"], "帰る đổi sang thể て thành 帰って."),
    ),
    (
        46, "N5", "comparison", "〜の中で〜がいちばん", "Trong số ~ thì ~ nhất",
        "Phạm vi + の中で + Đối tượng + がいちばん + Tính từ",
        "So sánh bậc nhất trong một tập hợp cùng loại (mùa, món ăn, môn thể thao...).",
        [("季節の中で春がいちばん好きです。", "Trong các mùa, tôi thích mùa xuân nhất."), ("日本料理の中で寿司がいちばんおいしいと思います。", "Trong đồ ăn Nhật tôi nghĩ sushi ngon nhất.")],
        ("Điền từ chỉ mức độ cao nhất: スポーツの中でサッカーが（　）おもしろいです。", ["いちばん", "もっと", "ほど", "ばかり"], 0, "Mẫu so sánh nhất trong phạm vi 〜の中で dùng いちばん."),
        ("果物の中（　）りんごがいちばん好きです。", ["で"], "Sau danh từ chỉ nhóm dùng の中で."),
    ),
    (
        47, "N5", "desire", "〜がほしい", "Muốn có (một đồ vật / điều gì)",
        "Danh từ + が + ほしいです（ngôi thứ nhất）",
        "Bày tỏ mong muốn sở hữu một đồ vật hay trạng thái cụ thể; khác 〜たい đi với động từ.",
        [("新しいパソコンがほしいです。", "Tôi muốn có một chiếc máy tính mới."), ("今、いちばんほしいものは時間です。", "Thứ tôi muốn nhất bây giờ là thời gian.")],
        ("Điền trợ từ đúng trước ほしい: 誕生日に時計（　）ほしいです。", ["を", "が", "に", "で"], 1, "Đối tượng mong muốn đi với ほしい luôn dùng trợ từ が."),
        ("寒いから、暖かい飲み物が（　）です。", ["ほしい", "欲しい"], "Muốn có đồ vật dùng tính từ ほしい."),
    ),
    (
        48, "N5", "quoting_noun", "〜の（名詞化）", "Danh từ hóa động từ / tính từ",
        "Động từ thể thông thường + の + が好き・上手・下手・速い...",
        "Biến cụm động từ thành cụm danh từ để làm chủ ngữ hoặc tân ngữ cho câu.",
        [("絵を描くのが好きです。", "Tôi thích vẽ tranh."), ("朝早く起きるのは大変です。", "Việc dậy sớm vào buổi sáng thật vất vả.")],
        ("Điền từ danh từ hóa động từ: 日本語で作文を（　）のは楽しいです。", ["書いて", "書きます", "書く", "書いた"], 2, "Trước の để danh từ hóa dùng động từ thể từ điển / thông thường."),
        ("料理を作る（　）が上手ですね。", ["の"], "Động từ 作る + の làm chủ ngữ cho 上手."),
    ),
    (
        49, "N5", "quoting_noun", "〜に行く・来る", "Đi / đến để làm việc gì (mục đích)",
        "Địa điểm + へ + (Động từ gốc ます / Danh từ) + に + 行きます・来ます",
        "Nêu mục đích của hành động di chuyển.",
        [("デパートへ靴を買いに行きます。", "Tôi đi trung tâm thương mại để mua giày."), ("日本へ経済の勉強に来ました。", "Tôi đến Nhật để học kinh tế.")],
        ("Chọn đúng hình thức trước に của động từ di chuyển: 友達と映画を（　）に行きます。", ["見る", "見て", "見た", "見"], 3, "Động từ đứng trước に chỉ mục đích phải bỏ ます (見ます -> 見)."),
        ("公園へ散歩（　）行きませんか。", ["に"], "Danh từ hoặc V(ます bỏ ます) kết hợp に + 行く."),
    ),
    (
        50, "N5", "giving_receiving", "〜あげる・〜もらう・〜くれる", "Tặng, nhận và được người khác tặng",
        "A は B に V(vật) を あげる / もらう / くれる",
        "あげます (tặng cho ai), もらいます (nhận từ ai), くれます (ai đó tặng cho mình/nhóm mình).",
        [("私は母に花をあげました。", "Tôi đã tặng hoa cho mẹ."), ("友だちが私に誕生日プレゼントをくれました。", "Bạn tôi đã tặng quà sinh nhật cho tôi.")],
        ("Chọn động từ khi người khác tặng cho mình: 兄が私に辞書を（　）。", ["くれました", "あげました", "もらいました", "しました"], 0, "Khi chủ ngữ là người khác tặng cho 私, dùng くれます / くれました."),
        ("私は先生に本を（　）。（Tôi nhận sách từ thầy）", ["もらいました"], "Tôi nhận từ ai dùng 私 は [người] に 〜 を もらう."),
    ),
    (
        51, "N5", "sequence", "〜まえに", "Trước khi làm việc gì",
        "Động từ thể từ điển / Danh từ + の + まえに",
        "Cho biết hành động ở vế sau diễn ra trước thời điểm hoặc hành động A; lưu ý động từ trước まえに luôn ở thể từ điển.",
        [("寝るまえに、歯を磨きます。", "Trước khi đi ngủ tôi đánh răng."), ("食事のまえに、手を洗いましょう。", "Trước bữa ăn hãy rửa tay nhé.")],
        ("Chọn dạng động từ đúng: 日本へ（　）まえに、ひらがなを覚えました。", ["行った", "行く", "行って", "行きます"], 1, "Dù cả câu ở quá khứ, động từ ngay trước まえに vẫn giữ thể từ điển (行く)."),
        ("授業（　）まえに、テキストを読んでおきます。", ["の"], "Trước まえに nếu là danh từ phải có trợ từ の."),
    ),

    # --- N4 (0052..0090 = 39 entries, total N4 = 45, grand total = 90) ---
    (
        52, "N4", "ability", "可能形（〜られる・〜える）", "Động từ thể khả năng (có thể làm)",
        "Nhóm I: u -> eru; Nhóm II: ru -> rareru; する -> できる; くる -> こられる",
        "Diễn tả năng lực hoặc điều kiện cho phép thực hiện hành động; đối tượng thường dùng trợ từ が.",
        [("私は漢字が少し読めます。", "Tôi có thể đọc được một ít chữ Hán."), ("この川では泳げません。", "Không thể bơi ở con sông này.")],
        ("Chọn thể khả năng của 話す: ミラーさんは日本語が上手に（　）。", ["話します", "話せます", "話させます", "話されます"], 1, "話す (nhóm I) chuyển đuôi u sang e + る thành 話せる -> 話せます."),
        ("目が悪くて、小さい字が（　）ません。", ["読め"], "読む chia thể khả năng là 読める -> 読めません."),
    ),
    (
        53, "N4", "aspect", "〜てある", "Được làm sẵn (trạng thái kết quả có chủ đích)",
        "N + が + Tha động từ thể て + ある",
        "Miêu tả trạng thái tồn tại hiện tại do ai đó đã chủ ý thực hiện hành động từ trước; trợ từ trước động từ chuyển sang が.",
        [("壁に地図が貼ってあります。", "Trên tường có dán sẵn bản đồ."), ("テーブルの上にお皿が並べてあります。", "Trên bàn đã bày sẵn đĩa rồi.")],
        ("Chọn thể phù hợp với ngữ cảnh phòng đã được chuẩn bị sẵn: 部屋の窓が（　）。", ["開いてあります", "開けてあります", "開けています", "開きました"], 1, "〜てある đi với tha động từ (開ける -> 開けてある) nêu trạng thái có chủ ý."),
        ("黒板に今日の予定が書い（　）あります。", ["て"], "書く -> 書いて + あります."),
    ),
    (
        54, "N4", "aspect", "〜ておく", "Làm sẵn trước để chuẩn bị",
        "Động từ thể て + おく（văn nói rút gọn thành とく）",
        "Thực hiện một hành động trước để chuẩn bị cho việc sắp diễn ra hoặc giữ nguyên trạng thái.",
        [("旅行の前に切符を買っておきます。", "Trước chuyến du lịch tôi mua sẵn vé."), ("会議の前に資料を配っておいてください。", "Trước cuộc họp hãy phát sẵn tài liệu nhé.")],
        ("Chọn mẫu 'làm sẵn trước': 客が来ますから、部屋を掃除して（　）。", ["います", "おきます", "みます", "しまいます"], 1, "Chuẩn bị sẵn sàng cho việc sắp tới dùng Vて + おきます."),
        ("明日の授業のために、単語を調べ（　）おきました。", ["て"], "調べる -> 調べて + おく."),
    ),
    (
        55, "N4", "aspect", "〜てしまう", "Làm xong hoàn toàn / lỡ làm (tiếc nuối)",
        "Động từ thể て + しまう（rút gọn: ちゃう・じゃう）",
        "Hai sắc thái chính: hoàn thành triệt để một việc gì, hoặc lỡ làm việc không mong muốn gây hối tiếc.",
        [("借りた本を全部読んでしまいました。", "Tôi đã đọc xong hết cuốn sách mượn rồi."), ("電車の中に傘を忘れてしまいました。", "Tôi lỡ quên mất chiếc ô trên tàu điện rồi.")],
        ("Chọn mẫu diễn tả sự lỡ quên đáng tiếc: 大切な約束を（　）。", ["忘れてしまいました", "忘れておきました", "忘れてみました", "忘れてありました"], 0, "Sự việc đáng tiếc hoặc hoàn tất dứt điểm dùng Vて + しまう."),
        ("宿題はさっき全部やって（　）ました。", ["しまい"], "やって + しまいました diễn tả đã làm xong hoàn toàn."),
    ),
    (
        56, "N4", "aspect", "〜てくる・〜ていく", "Tiến triển đến hiện tại / tiếp diễn về tương lai",
        "Động từ thể て + くる / いく",
        "〜てくる: thay đổi hoặc hành động hướng gần tới hiện tại/người nói; 〜ていく: biến đổi dần về tương lai hoặc rời xa dần.",
        [("最近、日本語がだんだんわかってきました。", "Gần đây tôi dần dần hiểu tiếng Nhật hơn rồi."), ("これからも日本語を勉強していきます。", "Từ giờ trở đi tôi vẫn sẽ tiếp tục học tiếng Nhật.")],
        ("Chọn đuôi phù hợp với bối cảnh 'gần đây trời trở lạnh dần tới nay': 最近、寒く（　）。", ["なっていきました", "なりましたから", "なってきました", "なっていました"], 2, "Biến đổi bắt đầu từ quá khứ tiến tới hiện tại dùng 〜てきました."),
        ("これからも健康に気をつけ（　）いきます。", ["て"], "Tiếp diễn hướng về tương lai dùng Vて + いく."),
    ),
    (
        57, "N4", "aspect", "〜はじめる・〜おわる", "Bắt đầu làm ~ / làm xong ~",
        "Động từ gốc ます + はじめる / おわる",
        "Nêu điểm khởi đầu hoặc kết thúc hoàn toàn của một hành động kéo dài.",
        [("急に雨が降りはじめました。", "Trời đột nhiên bắt đầu đổ mưa."), ("この小説をやっと読みおわりました。", "Cuối cùng tôi cũng đọc xong cuốn tiểu thuyết này.")],
        ("Chọn cách kết hợp đúng cho 'bắt đầu học': 先月から日本語を（　）。", ["習いはじめました", "習うはじめました", "習ってはじめました", "習ったはじめました"], 0, "Trước はじめる / おわる dùng động từ bỏ ます (習います -> 習い)."),
        ("ご飯を食べ（　）から、コーヒーを飲みましょう。", ["おわって", "終わって"], "Làm xong việc gì rồi làm tiếp dùng Vます + おわって."),
    ),
    (
        58, "N4", "aspect", "〜つづける", "Tiếp tục làm việc gì liên tục",
        "Động từ gốc ます + つづける",
        "Nhấn mạnh một hành động được duy trì đều đặn qua khoảng thời gian hoặc diễn ra không ngắt quãng.",
        [("三時間ずっと歩きつづけました。", "Tôi đã đi bộ liên tục suốt 3 tiếng."), ("あきらめないで努力しつづけたいです。", "Tôi muốn không bỏ cuộc mà tiếp tục nỗ lực.")],
        ("Chọn đúng dạng nối với つづける: 同じ会社で十年（　）。", ["働くつづけている", "働きつづけている", "働いてつづけている", "働かつづけている"], 1, "Động từ gốc ます bỏ ます + つづける (働きます -> 働きつづける)."),
        ("雨が朝からずっと降り（　）ています。", ["つづけ", "続け"], "降ります bỏ ます cộng つづけています."),
    ),
    (
        59, "N4", "tense_negation", "〜たばかり", "Vừa mới làm xong ~ (theo cảm nhận còn mới)",
        "Động từ thể た + ばかりだ",
        "Nhấn mạnh cảm nhận chủ quan của người nói rằng sự việc mới diễn ra chưa lâu (có thể vài giờ hoặc vài tháng).",
        [("先月日本へ来たばかりです。", "Tôi mới vừa đến Nhật tháng trước thôi."), ("さっき昼ご飯を食べたばかりなので、おなかがいっぱいです。", "Vì vừa mới ăn trưa lúc nãy nên bụng vẫn no.")],
        ("Chọn mẫu nhấn mạnh cảm giác 'mới vừa': 去年、大学を（　）ばかりです。", ["卒業する", "卒業した", "卒業して", "卒業しよう"], 1, "〜たばかり đứng sau động từ thể た."),
        ("この靴は先週買っ（　）ばかりなのに、もう壊れました。", ["た"], "買う đổi sang thể た thành 買った + ばかり."),
    ),
    (
        60, "N4", "tense_negation", "〜ところだ", "Sắp / đang đúng lúc / vừa mới ~",
        "Vる + ところ (sắp) / Vている + ところ (đang) / Vた + ところ (vừa mới)",
        "Chỉ thời điểm tức thì của hành động xét theo khoảnh khắc đang nói.",
        [("今から昼ご飯を食べるところです。", "Bây giờ tôi chuẩn bị ăn trưa đây."), ("ちょうど今、駅に着いたところです。", "Tôi vừa mới tới ga đúng lúc này.")],
        ("Chọn câu nghĩa 'vừa mới nấu xong ngay lúc này': ケーキが今（　）。", ["できたところです", "できるところです", "できているところです", "できそうです"], 0, "Hành động vừa hoàn tất ngay tức khắc dùng Vた + ところです."),
        ("今、友達にメールを送ってい（　）ところです。", ["る"], "Đang ngay giữa lúc làm hành động dùng Vている + ところ."),
    ),
    (
        61, "N4", "tense_negation", "〜ないで", "Làm B mà không làm A",
        "Động từ thể ない + で + Động từ chính",
        "Diễn tả trạng thái làm hành động thứ hai trong khi bỏ qua hành động thứ nhất vốn thường đi kèm.",
        [("今日は傘を持たないで出かけました。", "Hôm nay tôi ra ngoài mà không mang ô."), ("辞書を使わないで新聞を読みます。", "Tôi đọc báo mà không dùng từ điển.")],
        ("Chọn mẫu đúng: 朝ご飯を（　）、学校へ来てしまいました。", ["食べないで", "食べなくて", "食べなく", "食べたから"], 0, "Làm hành động chính mà không thực hiện hành động trước dùng Vないで."),
        ("砂糖を入れ（　）コーヒーを飲みます。", ["ないで"], "入らない/入れない -> 入れないで mang nghĩa 'không bỏ vào mà uống'."),
    ),
    (
        62, "N4", "tense_negation", "〜ずに", "Không làm A mà làm B (hơi trang trọng)",
        "Động từ thể ない bỏ ない + ずに (する -> せずに)",
        "Ý nghĩa tương tự 〜ないで nhưng mang sắc thái văn viết hoặc trang trọng hơn.",
        [("昨日、晩ご飯を食べずに寝てしまいました。", "Hôm qua tôi đã ngủ luôn mà không ăn tối."), ("誰にも相談せずに決めました。", "Tôi đã quyết định mà không bàn với ai.")],
        ("Chọn dạng đúng của する với ずに: メモを（　）、全部覚えました。", ["しないずに", "しずに", "せずに", "せずで"], 2, "Ngoại lệ của 〜ずに là する chuyển thành せずに."),
        ("昨日は勉強せ（　）寝てしまいました。", ["ずに"], "する kết hợp ずに luôn biến thành せずに."),
    ),
    (
        63, "N4", "condition", "〜と（条件）", "Hễ A thì tất yếu xảy ra B",
        "Thể từ điển / Thể ない + と、Mệnh đề kết quả",
        "Quy luật tự nhiên, thao tác máy móc, chỉ đường; vế sau không dùng câu mệnh lệnh, ý chí hay nhờ vả.",
        [("このボタンを押すと、おつりが出ます。", "Ấn nút này thì tiền thối sẽ ra."), ("春になると、桜が咲きます。", "Hễ sang xuân là hoa anh đào nở.")],
        ("Chọn vế sau đúng cho điều kiện tất yếu ～と: まっすぐ行くと、（　）。", ["左に銀行があります", "左を見てください", "銀行へ行きましょう", "写真を撮りたいです"], 0, "Với điều kiện tất yếu ～と, vế sau là sự thật khách quan chứ không phải mệnh lệnh hay ý định."),
        ("夜遅くまで起きている（　）、朝起きられません。", ["と"], "Hệ quả tự nhiên/thường thấy nối bằng と."),
    ),
    (
        64, "N4", "condition", "〜たら", "Nếu ~ / Sau khi ~ thì ~",
        "Thể quá khứ thông thường (〜た・〜かった・〜だった) + ら",
        "Dùng rất linh hoạt cho giả định, tình huống tương lai chắc chắn xảy ra, hoặc sau khi hoàn thành A; vế sau có thể là ý định, mời gọi.",
        [("雨が降ったら、試合は中止です。", "Nếu trời mưa thì trận đấu sẽ bị hủy."), ("家へ帰ったら、すぐ電話をください。", "Về đến nhà rồi hãy gọi cho tôi ngay nhé.")],
        ("Chọn thể đúng với たら: 時間が（　）、映画を見に行きませんか。", ["あるたら", "ありたら", "あったら", "あってら"], 2, "Quá khứ thông thường của ある là あった kết hợp ら thành あったら."),
        ("日本へ来（　）、ぜひ富士山を見たいです。", ["たら"], "来る -> 来た + ら (来たら)."),
    ),
    (
        65, "N4", "condition", "〜ば", "Nếu / Miễn là A thì B",
        "Nhóm I: u -> eba; Nhóm II: ru -> reba; Tính từ い -> ければ; ない -> なければ",
        "Nhấn mạnh điều kiện cần để kết quả ở vế sau xảy ra hoặc đưa ra giả định chung.",
        [("毎日練習すれば、上手になります。", "Nếu luyện tập mỗi ngày thì sẽ giỏi lên."), ("天気がよければ、散歩しましょう。", "Nếu thời tiết đẹp thì đi dạo nhé.")],
        ("Chọn thể điều kiện ば đúng của 読む: よく（　）、意味がわかります。", ["読めば", "読むば", "読みば", "読んでば"], 0, "読む đổi âm cuối u thành e + ば -> 読めば."),
        ("安（　）、そのパソコンを買いたいです。", ["ければ"], "Tính từ い (安い) bỏ い cộng ければ."),
    ),
    (
        66, "N4", "condition", "〜なら", "Nếu là nói về ~ (dựa vào thông tin vừa nghe)",
        "Danh từ / Tính từ な / Động từ thông thường + なら",
        "Đón lấy chủ đề hoặc lời đối phương vừa nói để đưa ra lời khuyên hay nhận xét phù hợp.",
        [("京都へ行くなら、秋がいちばんきれいですよ。", "Nếu đi Kyoto thì mùa thu là đẹp nhất đấy."), ("カメラなら、駅前の店が安いです。", "Nếu nói về máy ảnh thì cửa hàng trước ga rẻ lắm.")],
        ("Chọn từ điều kiện theo chủ đề người khác nêu: '東京へ行きたいです' — '東京へ行く（　）、新幹線が便利です。'", ["と", "なら", "たら", "から"], 1, "Tiếp nhận chủ đề đối phương nêu ra để khuyên dùng なら."),
        ("日本料理（　）、やはり寿司がおいしいです。", ["なら"], "Danh từ đi trực tiếp với なら để nêu chủ đề."),
    ),
    (
        67, "N4", "condition", "〜たらどうですか", "Bạn thử làm ~ xem sao? (gợi ý nhẹ nhàng)",
        "Động từ thể た + らどうですか",
        "Khuyên hoặc gợi ý cho người nghe một giải pháp để cân nhắc.",
        [("頭が痛いなら、少し休んだらどうですか。", "Nếu đau đầu thì bạn thử nghỉ một chút xem sao?"), ("先生に聞いてみたらどうですか。", "Sao bạn không thử hỏi thầy xem?")],
        ("Chọn cách gợi ý đúng: そんなに疲れているなら、早く（　）。", ["寝たらどうですか", "寝てどうですか", "寝るどうですか", "寝ますか"], 0, "Mẫu khuyên gợi ý là Vた + らどうですか."),
        ("一度病院へ（　）どうですか。", ["行ったら"], "行く đổi sang thể た + ら thành 行ったら."),
    ),
    (
        68, "N4", "reason_contrast", "〜ので", "Vì ~ nên ~ (lý do khách quan, lịch sự)",
        "Thể thông thường + ので (Tính từ な・Danh từ giữ な + ので)",
        "Giải thích nguyên nhân một cách khách quan, mềm mại hơn から, hay dùng khi xin phép hoặc xin lỗi.",
        [("バスが遅れたので、授業に間に合いませんでした。", "Vì xe buýt đến trễ nên tôi không kịp giờ học."), ("ここは静かなので、勉強しやすいです。", "Vì ở đây yên tĩnh nên rất dễ học.")],
        ("Chọn dạng liên kết đúng với ので: 明日は（　）、早く帰ります。", ["雨ので", "雨なので", "雨から", "雨だので"], 1, "Danh từ và tính từ đuôi な đứng trước ので phải thêm な."),
        ("急用ができた（　）、失礼します。", ["ので"], "Mệnh đề động từ thông thường + ので diễn tả lý do lịch sự."),
    ),
    (
        69, "N4", "reason_contrast", "〜のに", "Thế mà / Mặc dù ~ nhưng lại ~ (trái kỳ vọng)",
        "Thể thông thường + のに (Tính từ な・Danh từ giữ な + のに)",
        "Bày tỏ sự bất ngờ, thất vọng hoặc không hài lòng vì kết quả trái ngược hẳn với điều kiện ban đầu.",
        [("目覚まし時計をかけたのに、寝坊してしまいました。", "Đã đặt đồng hồ báo thức rồi vậy mà vẫn ngủ quên mất."), ("日曜日なのに、仕事に行かなければなりません。", "Dù là Chủ nhật mà vẫn phải đi làm.")],
        ("Chọn từ nối mang sắc thái ngạc nhiên/tiếc nuối: 薬を飲んだ（　）、まだ熱が下がりません。", ["ので", "から", "のに", "たら"], 2, "Kết quả trái mong đợi kèm cảm giác thất vọng dùng のに."),
        ("一生懸命勉強した（　）、テストに落ちてしまいました。", ["のに"], "Dù đã cố gắng nhưng kết quả trái ý -> のに."),
    ),
    (
        70, "N4", "reason_contrast", "〜ても", "Cho dù ~ đi nữa thì vẫn ~",
        "Động từ thể て + も / Tính từ い bỏ い + くても / Tính từ な・Danh từ + でも",
        "Nêu giả định điều kiện dù có xảy ra thì kết quả vẫn không đổi.",
        [("雨が降っても、サッカーの試合をします。", "Cho dù trời có mưa thì vẫn thi đấu bóng đá."), ("いくら高くても、この本を買いたいです。", "Dù có đắt thế nào tôi vẫn muốn mua cuốn sách này.")],
        ("Chọn dạng nhượng bộ đúng cho danh từ: （　）、仕事があります。", ["日曜日ても", "日曜日くても", "日曜日でも", "日曜日でても"], 2, "Danh từ và tính từ đuôi な kết hợp でも để nói 'dù là'."),
        ("何度聞いて（　）、よくわかりません。", ["も"], "Động từ thể て + も mang nghĩa 'cho dù đã làm... vẫn...'."),
    ),
    (
        71, "N4", "reason_contrast", "〜し、〜し", "Vừa ~ vừa ~ / Hơn nữa lại ~",
        "Thể thông thường + し、Thể thông thường + し",
        "Liệt kê nhiều đặc điểm đồng hướng hoặc nhiều lý do cộng dồn để giải thích cho kết luận.",
        [("この町は交通も便利だし、物価も安いです。", "Thành phố này giao thông vừa tiện, vật giá lại rẻ."), ("今日は忙しいし、天気も悪いし、家にいよう。", "Hôm nay vừa bận vừa thời tiết xấu nên ở nhà thôi.")],
        ("Chọn dạng đúng của tính từ な trước し: この店は料理がおいしいし、店員も（　）。", ["親切だし", "親切し", "親切なし", "親切でし"], 0, "Danh từ và tính từ đuôi な thể thông thường trước し dùng だ (親切だし)."),
        ("宿題も多い（　）、アルバイトもあります。", ["し"], "Liệt kê thêm lý do dùng trợ từ し."),
    ),
    (
        72, "N4", "reason_contrast", "〜て（原因・理由）", "Vì ~ mà (cảm xúc / kết quả không chủ ý)",
        "Động từ thể て / Tính từ い bỏ い + くて / Tính từ な + で",
        "Chỉ nguyên nhân nhẹ dẫn đến cảm xúc (vui, buồn, lo) hoặc tình huống ngoài ý muốn ở vế sau.",
        [("ニュースを聞いて、びっくりしました。", "Nghe tin tức mà tôi giật cả mình."), ("道が込んでいて、遅れてしまいました。", "Vì đường kẹt nên tôi bị trễ mất.")],
        ("Chọn mẫu chỉ nguyên nhân dẫn đến cảm xúc: あなたに会えて、（　）。", ["うれしいです", "会いましょう", "来てください", "行くつもりです"], 0, "Vế sau của mẫu nguyên nhân ～て chỉ cảm xúc hoặc trạng thái tự nhiên, không dùng ý chí."),
        ("風邪をひい（　）、頭が痛いです。", ["て"], "Nguyên nhân nhẹ gây trạng thái đau đầu dùng thể て."),
    ),
    (
        73, "N4", "adjectives", "〜すぎる", "Quá mức / vượt quá giới hạn",
        "Động từ gốc ます / Tính từ い bỏ い / Tính từ な + すぎる",
        "Nhận xét hành động hay tính chất vượt quá mức bình thường, thường mang sắc thái không tốt.",
        [("昨日、お酒を飲みすぎてしまいました。", "Hôm qua tôi đã uống quá nhiều rượu."), ("このセーターは私には大きすぎます。", "Chiếc áo len này quá rộng so với tôi.")],
        ("Chọn dạng kết hợp đúng với すぎる: このテストは（　）て、全然できません。", ["難しいすぎ", "難しすぎ", "難しくすぎ", "難しいなすぎ"], 1, "Tính từ đuôi い bỏ い rồi cộng すぎる (難しい -> 難しすぎる)."),
        ("甘いものを食べ（　）ないように気をつけます。", ["すぎ", "過ぎ"], "食べます bỏ ます cộng すぎない."),
    ),
    (
        74, "N4", "adjectives", "〜やすい・〜にくい", "Dễ làm ~ / Khó làm ~",
        "Động từ gốc ます + やすい（dễ）/ にくい（khó）",
        "Đánh giá tính chất khách quan của sự vật rằng nó thuận tiện hay gây khó khăn khi thực hiện.",
        [("このペンはとても書きやすいです。", "Cây bút này rất dễ viết."), ("この漢字は画数が多くて覚えにくいです。", "Chữ Hán này nhiều nét nên khó nhớ.")],
        ("Chọn cấu trúc diễn tả 'rất dễ hiểu': 先生の説明はとても（　）。", ["わかりにくい", "わかりやすい", "わかるやすい", "わかってやすい"], 1, "Động từ gốc ます (わかり) + やすい diễn tả sự dễ dàng."),
        ("この靴は軽くて歩き（　）です。", ["やすい"], "Nghĩa 'dễ đi lại' dùng Vます + やすい."),
    ),
    (
        75, "N4", "adjectives", "〜そうだ（様態）", "Trông có vẻ như ~ / Sắp sửa ~",
        "Động từ gốc ます / Tính từ い bỏ い / Tính từ な + そうだ",
        "Suy đoán bằng trực giác dựa trên vẻ ngoài quan sát được ngay lúc nói (lưu ý: いい -> よさそうだ, ない -> なさそうだ).",
        [("このケーキはとてもおいしそうですね。", "Chiếc bánh này trông ngon quá nhỉ."), ("今にも雨が降りそうです。", "Trời trông cứ như sắp mưa đến nơi rồi.")],
        ("Chọn dạng đúng cho động từ: 荷物が（　）そうですから、気をつけて。", ["落ち", "落ちる", "落ちた", "落ちて"], 0, "Trông sắp xảy ra dùng Vます bỏ ます + そうだ."),
        ("雲が黒くて、雨が降り（　）ですね。", ["そう"], "Quan sát thấy dấu hiệu sắp mưa -> 降りそうです."),
    ),
    (
        76, "N4", "adjectives", "〜がる", "Có vẻ muốn / tỏ ra cảm thấy ~ (ngôi thứ 3)",
        "Tính từ cảm xúc bỏ い / な + がる（thường chia がっている）",
        "Miêu tả cảm giác, mong muốn của người khác qua biểu hiện bên ngoài (chủ ngữ không phải người nói).",
        [("子供は新しいおもちゃをほしがっています。", "Đứa trẻ có vẻ rất muốn món đồ chơi mới."), ("妹は暗いところを怖がっています。", "Em gái tôi sợ chỗ tối.")],
        ("Chọn đúng cách diễn tả mong muốn của bạn A: リンさんは日本へ（　）。", ["行きたがっています", "行きたいです", "行ってほしいです", "行くつもり"], 0, "Nói về mong muốn ngôi thứ ba dùng 〜たがっている."),
        ("寒いので、犬が外へ出た（　）ません。", ["がり"], "〜たがる chia phủ định thành 〜たがりません."),
    ),
    (
        77, "N4", "request_suggestion", "〜てみる", "Làm thử xem sao",
        "Động từ thể て + みる",
        "Thử trải nghiệm một việc gì đó để kiểm tra hoặc biết cảm giác/kết quả ra sao.",
        [("日本の納豆を食べてみたいです。", "Tôi muốn ăn thử món natto của Nhật."), ("サイズが合うか、一度着てみてください。", "Hãy mặc thử một lần xem có vừa cỡ không.")],
        ("Chọn mẫu 'thử làm': おいしいかどうか、飲んで（　）ましょう。", ["おき", "み", "しまい", "あり"], 1, "Thử làm để biết cảm nhận dùng Vて + みる."),
        ("わからないときは、自分で考え（　）みてください。", ["て"], "考える -> 考えて + みる."),
    ),
    (
        78, "N4", "request_suggestion", "〜なさい", "Hãy làm ~ (mệnh lệnh nhẹ nhàng)",
        "Động từ gốc ます + なさい",
        "Thường dùng từ người lớn nói với trẻ nhỏ, thầy cô với học sinh hoặc trong đề thi.",
        [("早く寝なさい。明日は学校ですよ。", "Đi ngủ sớm đi con. Ngày mai đi học đấy."), ("次の文を読んで質問に答えなさい。", "Hãy đọc đoạn văn sau và trả lời câu hỏi.")],
        ("Chọn dạng đúng trước なさい: 毎日もっと野菜を（　）なさい。", ["食べる", "食べて", "食べ", "食べた"], 2, "Cấu trúc mệnh lệnh nhẹ dùng Vます bỏ ます + なさい."),
        ("教室に入ったら、静かに座り（　）。", ["なさい"], "Thể gốc ます (座ります) thay ます bằng なさい."),
    ),
    (
        79, "N4", "request_suggestion", "〜てほしい", "Muốn ai đó làm gì cho mình",
        "Người + に + Động từ thể て + ほしい",
        "Bày tỏ mong muốn người khác thực hiện hành động nào đó.",
        [("友達に手伝ってほしいです。", "Tôi muốn bạn giúp đỡ mình."), ("みんなに私の国へ来てほしいです。", "Tôi muốn mọi người đến thăm đất nước tôi.")],
        ("Chọn mẫu 'muốn ai làm gì': 私は弟にもっと勉強（　）。", ["してほしいです", "したいです", "してほしいで", "してあげたい"], 0, "Mong người khác làm cho dùng [Người] に Vて + ほしい."),
        ("忙しいときに、誰かに手伝っ（　）ほしいです。", ["て"], "手伝う -> 手伝って + ほしい."),
    ),
    (
        80, "N4", "intention", "〜ようと思う", "Tôi định sẽ làm ~ (dự định đang hình thành)",
        "Động từ thể ý chí (〜よう / 〜おう) + と思う（と思っている）",
        "Nêu ý định của người nói vừa nảy ra hoặc dự định mang tính cá nhân linh hoạt hơn つもり.",
        [("夏休みに国へ帰ろうと思っています。", "Tôi đang định nghỉ hè sẽ về quê hương."), ("来月から水泳を始めようと思います。", "Tôi định từ tháng sau sẽ bắt đầu học bơi.")],
        ("Chọn thể ý chí đúng của 行く: 来年、東京へ（　）と思っています。", ["行くよう", "行こう", "行けよう", "行ったよう"], 1, "Nhóm I 行く đổi âm u sang o + う -> 行こう."),
        ("もっと健康のために毎日歩こ（　）と思います。", ["う"], "歩こう dùng đuôi う ở thể ý chí."),
    ),
    (
        81, "N4", "intention", "〜予定だ", "Dự kiến / theo lịch trình sẽ ~",
        "Động từ thể từ điển / Danh từ + の + 予定だ",
        "Thông báo một kế hoạch, lịch trình đã được sắp xếp sẵn (thường mang tính lịch hẹn hoặc công việc).",
        [("来月の十日に出張する予定です。", "Theo lịch tôi sẽ đi công tác vào ngày 10 tháng sau."), ("会議は二時間の予定です。", "Cuộc họp dự kiến kéo dài hai tiếng.")],
        ("Chọn cách kết hợp đúng với danh từ: 来週は京都（　）予定です。", ["旅行するな", "旅行の", "旅行だ", "旅行に"], 1, "Danh từ đứng trước 予定 cần trợ từ の."),
        ("飛行機は午後三時に到着する（　）です。", ["予定"], "Động từ thể từ điển + 予定です diễn tả lịch trình."),
    ),
    (
        82, "N4", "intention", "〜ことにする・〜ことになる", "Tự quyết định / được quyết định rằng",
        "Vる・Vない + ことにする（chủ động）/ + ことになる（khách quan）",
        "ことにする: bản thân tự quyết định; ことになる: tổ chức/hoàn cảnh quyết định không phụ thuộc ý muốn cá nhân.",
        [("健康のために、毎日歩くことにしました。", "Vì sức khỏe, tôi đã quyết định mỗi ngày sẽ đi bộ."), ("来月、大阪へ転勤することになりました。", "Tháng sau tôi được điều chuyển công tác tới Osaka.")],
        ("Chọn câu thể hiện quyết định từ công ty/tập thể: 会議で新しいルールを作る（　）。", ["ことにしました", "ことになりました", "つもりです", "ようです"], 1, "Quyết định khách quan từ tập thể dùng 〜ことになる."),
        ("もう遅いから、今日はここで帰る（　）にします。", ["こと"], "Tự bản thân quyết định dùng ことにする."),
    ),
    (
        83, "N4", "quoting_noun", "〜と思う", "Tôi nghĩ rằng ~ (trích dẫn suy nghĩ)",
        "Thể thông thường + と思う",
        "Trình bày ý kiến, suy đoán của bản thân; khi hỏi ý kiến người khác dùng と思いますか.",
        [("明日は雨が降ると思います。", "Tôi nghĩ ngày mai trời sẽ mưa."), ("日本の生活はどう思いますか。", "Bạn nghĩ sao về cuộc sống ở Nhật?")],
        ("Chọn dạng đúng trước と思う: この映画はとてもおもしろい（　）思います。", ["だ", "と", "を", "が"], 1, "Trích dẫn nội dung suy nghĩ luôn dùng trợ từ と."),
        ("彼はおそらくもう駅に着いた（　）思います。", ["と"], "Thể thông thường + と + と思う."),
    ),
    (
        84, "N4", "quoting_noun", "〜と言う", "Nói rằng ~ (tường thuật lời nói)",
        "Thể thông thường / 「Câu trực tiếp」 + と言う",
        "Thuật lại lời nói gián tiếp hoặc trích nguyên văn lời ai đó đã nói.",
        [("先生は明日テストがあると言いました。", "Thầy giáo nói rằng ngày mai có bài kiểm tra."), ("田中さんは「ちょっと遅れます」と言っていました。", "Anh Tanaka nói là 'Tôi sẽ đến muộn một chút'."),],
        ("Chọn đúng hình thức tường thuật: 友達は「また明日」と（　）。", ["思いました", "言いました", "聞きました", "話しました"], 1, "Thuật lại câu nói trực tiếp trong dấu ngoặc dùng と言いました."),
        ("母は体に気をつけなさい（　）言いました。", ["と"], "Trước 言いました dùng trợ từ trích dẫn と."),
    ),
    (
        85, "N4", "quoting_noun", "〜かどうか", "Liệu có ~ hay không",
        "Thể thông thường + かどうか",
        "Lồng ghép một câu hỏi Có/Không vào làm tân ngữ cho động từ biết, nhớ, hỏi, kiểm tra...",
        [("明日、彼が来るかどうかわかりません。", "Tôi không biết ngày mai anh ấy có đến hay không."), ("この料理が辛いかどうか食べてみます。", "Tôi ăn thử xem món này có cay hay không.")],
        ("Chọn mẫu 'có đúng không/có hay không': 鍵をかけた（　）忘れてしまいました。", ["か", "かどうか", "のか", "ところ"], 1, "Nghi vấn dạng có/không trong câu ghép dùng かどうか."),
        ("サイズが合う（　）どうか、履いてみてください。", ["か"], "Cụm かどうか gắn sau thể thông thường."),
    ),
    (
        86, "N4", "quoting_noun", "〜ために", "Để ~ (mục đích) / Vì ~ (nguyên nhân)",
        "Động từ thể từ điển / Danh từ + の + ために",
        "Trước động từ ý chí chỉ mục đích cần cố gắng đạt được; hoặc nêu nguyên nhân gây tác động ở danh từ.",
        [("自分の店を持つために、お金をためています。", "Tôi đang tiết kiệm tiền để có cửa hàng riêng."), ("台風のために電車が止まりました。", "Vì bão nên tàu điện đã dừng chạy.")],
        ("Chọn từ nối đúng sau danh từ chỉ mục đích: 将来（　）ために、毎日貯金しています。", ["の", "な", "に", "で"], 0, "Danh từ đứng trước ために phải thêm trợ từ の."),
        ("日本語が上手になる（　）、毎日ニュースを聞いています。", ["ために"], "Động từ có chủ ý đạt mục tiêu đi với ために."),
    ),
    (
        87, "N4", "quoting_noun", "〜ように", "Để có thể đạt tới trạng thái ~",
        "Động từ khả năng / Động từ thể ない / Tự động từ + ように",
        "Khác với ために, dùng với động từ không mang ý chí trực tiếp (có thể làm, trở nên, không bị quên) để nêu mục tiêu.",
        [("忘れないようにメモします。", "Tôi ghi chú lại để không bị quên."), ("早く日本語が話せるように毎日練習します。", "Tôi luyện tập mỗi ngày để có thể nói tiếng Nhật sớm.")],
        ("Chọn mẫu đúng với động từ khả năng/phủ định: 遅刻（　）ように、早く家を出ます。", ["する", "しない", "した", "して"], 1, "Mục tiêu tránh điều ngoài ý muốn dùng Vない + ように."),
        ("後ろの人にも聞こえる（　）、大きい声で話します。", ["ように"], "Động từ 聞こえる (không chủ ý) đi với ように."),
    ),
    (
        88, "N4", "giving_receiving", "〜てあげる・〜てもらう・〜てくれる", "Làm giúp / nhờ làm / được ai làm cho",
        "Động từ thể て + あげる / もらう / くれる",
        "Diễn tả ân huệ hành động giữa người thực hiện và người nhận lợi ích.",
        [("私は友達に漢字の読み方を教えてあげました。", "Tôi đã dạy bạn cách đọc chữ Hán."), ("先輩にパソコンを直してもらいました。", "Tôi đã nhờ anh khóa trên sửa máy tính giúp.")],
        ("Chọn mẫu khi bạn được người khác giúp đỡ: 友達が駅まで車で送って（　）。", ["くれました", "あげました", "もらいました", "しました"], 0, "Chủ ngữ là 友達 làm hành động giúp tôi dùng てくれた / てくれました."),
        ("私は妹の宿題を手伝っ（　）あげました。", ["て"], "手伝う -> 手伝って + あげる."),
    ),
    (
        89, "N4", "voice_politeness", "受身形（〜られる・〜れる）", "Thể bị động (bị / được ai làm gì)",
        "Nhóm I: u -> areru; Nhóm II: ru -> rareru; する -> される; くる -> こられる",
        "Người hoặc vật chịu tác động từ hành động của người khác (thường dùng với に trước tác nhân).",
        [("私は先生にほめられました。", "Tôi đã được thầy giáo khen."), ("電車の中で隣の人に足を踏まれました。", "Trên tàu tôi bị người bên cạnh giẫm lên chân.")],
        ("Chọn thể bị động đúng của 叱る: 遅刻して、課長に（　）。", ["叱りました", "叱らせました", "叱られました", "叱れました"], 2, "叱る (nhóm I) chia bị động thành 叱られる -> 叱られました."),
        ("雨に降ら（　）、服がぬれてしまいました。", ["れて"], "Bị động của 降る là 降られる -> 降られて (bị dính mưa)."),
    ),
    (
        90, "N4", "voice_politeness", "〜かもしれない", "Có lẽ / biết đâu chừng ~",
        "Thể thông thường + かもしれない (Danh từ・Tính từ な không thêm だ)",
        "Nêu phán đoán với xác suất chưa chắc chắn (khoảng 50%).",
        [("午後から雪が降るかもしれません。", "Từ chiều trở đi có lẽ tuyết sẽ rơi."), ("彼はもう帰ったかもしれません。", "Có khi anh ấy đã về rồi cũng nên.")],
        ("Chọn cách kết hợp đúng sau danh từ: 次のバスが最終（　）しれません。", ["だかも", "のかも", "かも", "なかも"], 2, "Danh từ và tính từ đuôi な đi thẳng với かもしれない, không dùng だ."),
        ("道が込んでいるので、少し遅れる（　）しれません。", ["かも"], "Cụm かもしれない diễn tả khả năng có thể xảy ra."),
    ),
]


def load_b0():
    b0_grammar = json.loads((B0_DIR / "grammar.draft.json").read_text(encoding="utf-8"))
    b0_questions = json.loads((B0_DIR / "questions.draft.json").read_text(encoding="utf-8"))
    return b0_grammar["grammar_points"], b0_questions["questions"]


def sql_str(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def build_all():
    grammar_points, b0_questions = load_b0()
    questions = []
    for q in b0_questions:
        # Normalize to canonical practice_questions schema while preserving every B0 field.
        row = {
            "id": q["id"],
            "grammar_id": q["grammar_id"],
            "content_version": q["content_version"],
            "question_type": q["type"],
            "prompt": q["prompt"],
            "options": q.get("options"),
            "correct_option_index": q.get("correct_option_index"),
            "accepted_answers": q.get("accepted_answers"),
            "normalization": q.get("normalization", "trim_only"),
            "explanation_vi": q["explanation_vi"],
        }
        questions.append(row)

    next_q_num = len(questions) + 1
    for entry in NEW_ENTRIES:
        (
            idx,
            level,
            category,
            pattern,
            meaning_vi,
            formula,
            usage_vi,
            examples,
            mcq,
            cloze,
        ) = entry
        g_id = f"10000000-0000-0000-0000-{idx:012d}"
        assert category in ALLOWED_CATEGORIES, f"Unknown category: {category}"
        assert level in ("N5", "N4")
        grammar_points.append(
            {
                "id": g_id,
                "pattern": pattern,
                "level": level,
                "category": category,
                "meaning_vi": meaning_vi,
                "formula": formula,
                "usage_vi": usage_vi,
                "grammar_examples": [
                    {"sentence_ja": s_ja, "translation_vi": s_vi}
                    for s_ja, s_vi in examples
                ],
            }
        )

        m_prompt, m_opts, m_idx, m_exp = mcq
        assert len(m_opts) == 4 and len(set(m_opts)) == 4, f"Bad MCQ options at {idx}: {m_opts}"
        assert 0 <= m_idx < 4
        questions.append(
            {
                "id": f"20000000-0000-0000-0000-{next_q_num:012d}",
                "grammar_id": g_id,
                "content_version": 1,
                "question_type": "mcq",
                "prompt": m_prompt,
                "options": m_opts,
                "correct_option_index": m_idx,
                "accepted_answers": None,
                "normalization": "trim_only",
                "explanation_vi": m_exp,
            }
        )
        next_q_num += 1

        c_prompt, c_answers, c_exp = cloze
        assert c_prompt.count("（　）") == 1, f"Cloze must contain 1 blank at {idx}: {c_prompt}"
        assert c_answers and all(a == a.strip() and a for a in c_answers)
        questions.append(
            {
                "id": f"20000000-0000-0000-0000-{next_q_num:012d}",
                "grammar_id": g_id,
                "content_version": 1,
                "question_type": "cloze",
                "prompt": c_prompt,
                "options": None,
                "correct_option_index": None,
                "accepted_answers": c_answers,
                "normalization": "trim_only",
                "explanation_vi": c_exp,
            }
        )
        next_q_num += 1

    # Validate global invariants.
    assert 80 <= len(grammar_points) <= 120, f"Expected 80..120 grammar points, got {len(grammar_points)}"
    assert len(questions) >= 160, f"Expected >= 160 questions, got {len(questions)}"
    g_ids = [g["id"] for g in grammar_points]
    g_patterns = [g["pattern"] for g in grammar_points]
    q_ids = [q["id"] for q in questions]
    assert len(set(g_ids)) == len(g_ids)
    assert len(set(g_patterns)) == len(g_patterns), "Duplicate grammar pattern found!"
    assert len(set(q_ids)) == len(q_ids)
    for uid in g_ids + q_ids:
        UUID(uid)

    n5_count = sum(1 for g in grammar_points if g["level"] == "N5")
    n4_count = sum(1 for g in grammar_points if g["level"] == "N4")
    print(f"Validated {len(grammar_points)} grammar points ({n5_count} N5, {n4_count} N4) and {len(questions)} questions.")

    # Write assets/data/grammar.json
    (ROOT / "assets/data/grammar.json").write_text(
        json.dumps(grammar_points, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    # Write assets/data/practice_questions.json
    (ROOT / "assets/data/practice_questions.json").write_text(
        json.dumps(questions, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    # Write supabase/seed.sql
    sql_lines = [
        "-- AI-authored draft JLPT N5/N4 curriculum seed (90 grammar points, 180 practice questions).",
        "-- First 12 grammar points preserve B0 integration fixtures verbatim; all drafts remain pending human pedagogical review.",
        "",
    ]
    for g in grammar_points:
        sql_lines.append(
            "insert into public.grammar_points (id, pattern, level, category, meaning_vi, formula, usage_vi) "
            f"values ({sql_str(g['id'])}, {sql_str(g['pattern'])}, {sql_str(g['level'])}, {sql_str(g['category'])}, "
            f"{sql_str(g['meaning_vi'])}, {sql_str(g['formula'])}, {sql_str(g['usage_vi'])}) "
            "on conflict (id) do nothing;"
        )
        for sort_order, ex in enumerate(g["grammar_examples"]):
            sql_lines.append(
                "insert into public.grammar_examples (grammar_id, sentence_ja, translation_vi, sort_order) "
                f"values ({sql_str(g['id'])}, {sql_str(ex['sentence_ja'])}, {sql_str(ex['translation_vi'])}, {sort_order}) "
                "on conflict (grammar_id, sort_order) do nothing;"
            )

    sql_lines.append("")
    for q in questions:
        opts_sql = (
            sql_str(json.dumps(q["options"], ensure_ascii=False)) + "::jsonb"
            if q["options"] is not None
            else "null"
        )
        corr_sql = (
            str(q["correct_option_index"])
            if q["correct_option_index"] is not None
            else "null"
        )
        ans_sql = (
            sql_str(json.dumps(q["accepted_answers"], ensure_ascii=False)) + "::jsonb"
            if q["accepted_answers"] is not None
            else "null"
        )
        sql_lines.append(
            "insert into public.practice_questions "
            "(id, grammar_id, content_version, question_type, prompt, options, correct_option_index, accepted_answers, normalization, explanation_vi) "
            f"values ({sql_str(q['id'])}, {sql_str(q['grammar_id'])}, {q['content_version']}, {sql_str(q['question_type'])}, "
            f"{sql_str(q['prompt'])}, {opts_sql}, {corr_sql}, {ans_sql}, {sql_str(q['normalization'])}, {sql_str(q['explanation_vi'])}) "
            "on conflict (id) do nothing;"
        )

    (ROOT / "supabase/seed.sql").write_text("\n".join(sql_lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    build_all()

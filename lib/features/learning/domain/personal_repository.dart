enum LearningStatus {
  fresh('new', 'Mới'),
  learning('learning', 'Đang học'),
  review('review', 'Cần ôn'),
  mastered('mastered', 'Đã nắm');

  const LearningStatus(this.value, this.label);
  final String value;
  final String label;
  static LearningStatus parse(String? value) =>
      values.firstWhere((status) => status.value == value, orElse: () => fresh);
}

class UserProfile {
  const UserProfile({
    this.displayName = '',
    this.level = 'N5',
    this.goal = '',
    this.dailyMinutes = 15,
  });
  final String displayName;
  final String level;
  final String goal;
  final int dailyMinutes;
}

class LearningSummary {
  const LearningSummary(this.saved, this.statuses);
  final Set<String> saved;
  final Map<String, LearningStatus> statuses;
  LearningStatus statusOf(String id) => statuses[id] ?? LearningStatus.fresh;
}

abstract interface class PersonalRepository {
  Stream<UserProfile> watchProfile();
  Future<void> saveProfile(UserProfile profile);
  Stream<LearningSummary> watchSummary();
  Future<void> setSaved(String grammarId, bool saved);
  Future<void> setStatus(String grammarId, LearningStatus status);
  Future<void> deleteNote(String noteId);
}

class UpdateLearning {
  const UpdateLearning(this.repository);
  final PersonalRepository repository;
  Future<void> saveProfile(UserProfile profile) {
    if (!{'N5', 'N4'}.contains(profile.level) ||
        profile.dailyMinutes < 1 ||
        profile.dailyMinutes > 1440 ||
        profile.displayName.trim().runes.length > 100 ||
        profile.goal.trim().runes.length > 500) {
      throw const FormatException(
        'Hồ sơ không hợp lệ. Thời gian học từ 1 đến 1440 phút.',
      );
    }
    return repository.saveProfile(
      UserProfile(
        displayName: profile.displayName.trim(),
        level: profile.level,
        goal: profile.goal.trim(),
        dailyMinutes: profile.dailyMinutes,
      ),
    );
  }

  Future<void> setSaved(String grammarId, bool saved) =>
      repository.setSaved(grammarId, saved);
  Future<void> setStatus(String grammarId, LearningStatus status) =>
      repository.setStatus(grammarId, status);
  Future<void> deleteNote(String id) => repository.deleteNote(id);
}

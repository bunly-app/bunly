import '../domain/demo_practice.dart';

/// UI exercise samples from user-supplied HTML, not the approved question bank.
class StitchDemoPractice implements DemoPracticeRepository {
  const StitchDemoPractice();
  @override
  List<PracticeQuestion> questions() => const [
    PracticeQuestion(
      kind: PracticeKind.choice,
      prompt: '日本へ旅行に（　？　）ことがあります。富士山がとても綺麗でした。',
      context:
          'Chọn dạng động từ diễn tả trải nghiệm đã từng đi du lịch Nhật Bản.',
      options: ['行く', '行った', '行きます', '行かない'],
      accepted: ['行った'],
      explanation:
          'V-た + ことがある nói về trải nghiệm đã từng làm. 行く đổi sang thể た là 行った.',
    ),
    PracticeQuestion(
      kind: PracticeKind.cloze,
      prompt: '納豆を［　　　］ことがありません。',
      context: 'Tôi chưa từng ăn món đậu nành lên men nattō bao giờ.',
      options: ['食べた', '食べる', '食べて', '食べない'],
      accepted: ['食べた', 'たべた'],
      explanation:
          'Dạng phủ định vẫn dùng V-た + ことがありません. Câu mẫu chấp nhận 食べた hoặc たべた; chỉ bỏ khoảng trắng ở hai đầu.',
    ),
  ];
}

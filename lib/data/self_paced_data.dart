import '../models/selfpaces_course_model.dart';

class SelfPacedData {
  static List<CourseModel> courses = [
    /// 1
    CourseModel(
      id: "1",
      title: "Yoga Fundamentals for Beginners",

      description:
          "Master the basic yoga poses,\n"
          "breathing techniques, and foundational",

      instructor: "Priya Sharma",

      duration: "6 hours",

      level: "Beginner",

      rating: "4.9",

      image: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",

      enrolled: true,
      completed: false,

      progress: .33,

      lessonsText: "8 of 24 lessons",

      showProgress: true,
      showEnrollButton: false,

      actionText: "Continue Learning",
    ),

    /// 2
    CourseModel(
      id: "2",
      title: "Advanced Asana Mastery",

      description:
          "Deepen your practice with advanced\n"
          "poses, inversions, and complex",

      instructor: "Rohan Desai",

      duration: "10 hours",

      level: "Advanced",

      rating: "4.8",

      image: "https://images.unsplash.com/photo-1506126613408-eca07ce68773",

      enrolled: true,
      completed: true,

      progress: 1,

      lessonsText: "40 of 40 lessons",

      showProgress: true,
      showEnrollButton: false,

      actionText: "Review Course",
    ),

    /// 3
    CourseModel(
      id: "3",
      title: "Pranayama & Breathwork Essentials",

      description:
          "Learn powerful breathing techniques\n"
          "to enhance your energy, reduce",

      instructor: "Anjali Menon",

      duration: "4 hours",

      level: "Intermediate",

      rating: "5",

      image: "https://images.unsplash.com/photo-1552196563-55cd4e45efb3",

      enrolled: true,
      completed: false,

      progress: .31,

      lessonsText: "5 of 16 lessons",

      showProgress: true,
      showEnrollButton: false,

      actionText: "Continue Learning",
    ),

    /// 4 Meditation
    CourseModel(
      id: "4",
      title: "Meditation & Mindfulness Journey",

      description:
          "Develop a consistent meditation practice with guided sessions ranging",

      instructor: "Vikram Patel",

      duration: "5 hours",

      level: "Beginner",

      rating: "4.9",

      image: "https://images.unsplash.com/photo-1526401485004-2fda9f3f1c9b",

      enrolled: false,
      completed: false,

      progress: null,
      lessonsText: null,

      showProgress: false,
      showEnrollButton: true,

      actionText: " ",
    ),

    /// 5 Flexibility
    CourseModel(
      id: "5",
      title: "Yoga for Flexibility & Strength",

      description:
          "Build strength and increase flexibility through targeted sequences focusing",

      instructor: "Kavita Singh",

      duration: "8 hours",

      level: "Intermediate",

      rating: "4.7",

      image: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b",

      enrolled: false,
      completed: false,

      progress: null,
      lessonsText: null,

      showProgress: false,
      showEnrollButton: true,

      actionText: "Enroll Now",
    ),

    /// 6 Restorative
    CourseModel(
      id: "6",
      title: "Restorative Yoga & Healing",

      description:
          "Gentle, therapeutic practices designed\n"
          "to promote deep relaxation, stress",

      instructor: "Meera Iyer",

      duration: "6 hours",

      level: "Beginner",

      rating: "4.9",

      image: "https://images.unsplash.com/photo-1552196563-55cd4e45efb3",

      enrolled: false,
      completed: false,

      progress: null,
      lessonsText: null,

      showProgress: false,
      showEnrollButton: true,

      actionText: "Enroll Now",
    ),
  ];
}

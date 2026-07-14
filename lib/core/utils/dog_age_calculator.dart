class DogAgeCalculator {
  static int ageFromBirthday(DateTime? birthday) {
    if (birthday == null) {
      return 0;
    }

    final now = DateTime.now();
    var age = now.year - birthday.year;
    final hasNotHadBirthday =
        now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day);

    if (hasNotHadBirthday) {
      age -= 1;
    }
    return age < 0 ? 0 : age;
  }
}

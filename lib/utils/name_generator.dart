import 'dart:math';

class NameGenerator {
  static final Random _random = Random();

  // Simple lists for now, can be expanded and categorized later
  static const List<String> _firstNames = [
    // Common English/European names
    "James", "John", "Robert", "Michael", "William", "David", "Richard",
    "Joseph", "Thomas", "Charles",
    "Christopher", "Daniel", "Matthew", "Anthony", "Mark", "Donald", "Steven",
    "Paul", "Andrew", "Joshua",
    "Kevin", "Brian", "George", "Edward", "Ronald", "Timothy", "Jason",
    "Jeffrey", "Ryan", "Jacob",
    "Gary", "Nicholas", "Eric", "Jonathan", "Stephen", "Larry", "Justin",
    "Scott", "Brandon", "Benjamin",
    "Samuel", "Gregory", "Frank", "Alexander", "Patrick", "Raymond", "Jack",
    "Dennis", "Jerry", "Tyler",
    "Aaron", "Jose", "Adam", "Henry", "Nathan", "Douglas", "Zachary", "Peter",
    "Kyle", "Walter",
    // Common Spanish/Portuguese names
    "Santiago", "Mateo", "Sebastián", "Leonardo", "Matías", "Emiliano", "Diego",
    "Miguel", "Iker", "Alejandro",
    "João", "Lucas", "Pedro", "Gabriel", "Arthur", "Bernardo", "Heitor",
    "Rafael", "Davi", "Lorenzo",
    // Common German names
    "Lukas", "Finn", "Jonas", "Felix", "Leon", "Paul", "Noah", "Ben", "Elias",
    "Maximilian",
    // Common French names
    "Lucas", "Gabriel", "Léo", "Raphaël", "Arthur", "Louis", "Jules", "Adam",
    "Maël", "Hugo",
    // Common Italian names
    "Leonardo", "Francesco", "Alessandro", "Lorenzo", "Mattia", "Andrea",
    "Gabriele", "Riccardo", "Tommaso", "Edoardo",
    // Common Dutch names
    "Noah", "Sem", "Liam", "Lucas", "Daan", "Finn", "Levi", "Luuk", "Mees",
    "James",
    // Common Scandinavian names
    "William", "Oscar", "Lucas", "Oliver", "Noah", "Elias", "Hugo", "Liam",
    "Emil", "Viktor",
    // Common Eastern European names
    "Jakub", "Jan", "Tomas", "Filip", "Lukas", "Adam", "Matej", "Vojtech",
    "Dominik", "David",
    "Ivan", "Dmitry", "Maxim", "Artem", "Alexander", "Mikhail", "Nikita",
    "Andrei", "Sergei", "Vladimir",
    // Common Asian names (Sample - needs more diversity)
    "Kenji", "Haruto", "Yuto", "Sota", "Ren", "Min-jun", "Seo-jun", "Ha-joon",
    "Do-yun", "Eun-woo",
    "Wei", "Hao", "Chen", "Li", "Zhang", "Wang", "Liu", "Yang", "Huang", "Zhao",
    // Common African names (Sample - needs more diversity)
    "Kwame", "Kofi", "Yaw", "Kwabena", "Akwasi", "Kwasi", "Kwadwo", "Kwaku",
    "Yaw", "Kofi",
    "Ahmed", "Mohamed", "Ali", "Omar", "Yusuf", "Ibrahim", "Hassan", "Mustafa",
    "Abdi", "Said",
    // Common Indian names (Sample - needs more diversity)
    "Aarav", "Vihaan", "Vivaan", "Ananya", "Diya", "Advik", "Kabir", "Anika",
    "Ayaan", "Ishaan",
    "Rohan", "Arjun", "Sai", "Aryan", "Reyansh", "Krishna", "Ishaan", "Shaurya",
    "Atharv", "Aadi",
  ];

  static const List<String> _lastNames = [
    // Common English/European surnames
    "Smith", "Jones", "Williams", "Brown", "Taylor", "Davies", "Wilson",
    "Evans", "Thomas", "Johnson",
    "Roberts", "Walker", "Wright", "White", "Harris", "Clark", "Lewis", "Young",
    "Hall", "Allen",
    "King", "Scott", "Green", "Adams", "Baker", "Nelson", "Carter", "Mitchell",
    "Perez", "Campbell",
    "Parker", "Edwards", "Collins", "Stewart", "Sanchez", "Morris", "Rogers",
    "Reed", "Cook", "Morgan",
    "Bell", "Murphy", "Bailey", "Rivera", "Cooper", "Richardson", "Cox",
    "Howard", "Ward", "Torres",
    // Common Spanish/Portuguese surnames
    "García", "Rodríguez", "González", "Fernández", "López", "Martínez",
    "Sánchez", "Pérez", "Gómez", "Martín",
    "Silva", "Santos", "Ferreira", "Pereira", "Oliveira", "Costa", "Rodrigues",
    "Martins", "Jesus", "Sousa",
    // Common German surnames
    "Müller", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer", "Wagner",
    "Becker", "Schulz", "Hoffmann",
    // Common French surnames
    "Martin", "Bernard", "Dubois", "Thomas", "Robert", "Richard", "Petit",
    "Durand", "Leroy", "Moreau",
    // Common Italian surnames
    "Rossi", "Russo", "Ferrari", "Esposito", "Bianchi", "Romano", "Colombo",
    "Ricci", "Marino", "Greco",
    // Common Dutch surnames
    "de Jong", "Jansen", "de Vries", "van den Berg", "van Dijk", "Bakker",
    "Janssen", "Visser", "Smit", "Meijer",
    // Common Scandinavian surnames
    "Hansen", "Johansen", "Olsen", "Larsen", "Andersen", "Pedersen", "Nilsen",
    "Kristiansen", "Jensen", "Karlsson",
    // Common Eastern European surnames
    "Novák", "Svoboda", "Novotný", "Dvořák", "Černý", "Procházka", "Kučera",
    "Veselý", "Horák", "Němec",
    "Ivanov", "Smirnov", "Kuznetsov", "Popov", "Vasiliev", "Petrov", "Sokolov",
    "Mikhailov", "Fedorov", "Morozov",
    // Common Asian surnames (Sample)
    "Sato", "Suzuki", "Takahashi", "Tanaka", "Watanabe", "Kim", "Lee", "Park",
    "Choi", "Jeong",
    "Wang", "Li", "Zhang", "Liu", "Chen", "Yang", "Huang", "Zhao", "Wu", "Zhou",
    // Common African surnames (Sample)
    "Nkosi", "Dlamini", "Mensah", "Osei", "Adebayo", "Okonkwo", "Diallo",
    "Traoré", "Keita", "Diop",
    "Mohamed", "Ali", "Hassan", "Ahmed", "Hussein", "Omar", "Ibrahim", "Abdi",
    "Osman", "Jama",
    // Common Indian surnames (Sample)
    "Sharma", "Verma", "Gupta", "Singh", "Kumar", "Patel", "Shah", "Das",
    "Khan", "Reddy",
    "Jain", "Yadav", "Mishra", "Chopra", "Mehta", "Rao", "Malhotra", "Kapoor",
    "Agarwal", "Bose",
  ];

  static String generatePlayerName() {
    String firstName = _firstNames[_random.nextInt(_firstNames.length)];
    String lastName = _lastNames[_random.nextInt(_lastNames.length)];
    return "$firstName $lastName";
  }
}

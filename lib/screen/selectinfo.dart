import 'package:flutter/material.dart';

class SelectInfoScreen extends StatefulWidget {
  @override
  _SelectInfoScreenState createState() => _SelectInfoScreenState();
}

class _SelectInfoScreenState extends State<SelectInfoScreen> {
  String _selectedGender = 'Select Gender';
  String _selectedDisease = 'Select Disease';

  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController allergyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                const CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/images/food4.png'),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Welcome...',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jua',
                    color: Color.fromRGBO(42, 80, 90, 1),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoSection(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement your logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 197, 66, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เพศ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildDropdownButton(_selectedGender, (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          }, ['Select Gender', 'ชาย', 'หญิง']),
          const SizedBox(height: 10),
          _buildTextField(ageController, 'อายุ'),
          const SizedBox(height: 10),
          _buildTextField(weightController, 'น้ำหนัก (กก.)'),
          const SizedBox(height: 10),
          _buildTextField(heightController, 'ส่วนสูง (ซม.)'),
          const SizedBox(height: 10),
          const Text(
            'โรคที่เป็น',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildDropdownButton(_selectedDisease, (String? newValue) {
            setState(() {
              _selectedDisease = newValue!;
            });
          }, ['Select Disease', 'โรคอ้วน', 'โรคไต', 'โรคความดันโลหิตสูง', 'ไม่เป็นโรค']),
          const SizedBox(height: 10),
          _buildTextField(allergyController, 'อาหารที่แพ้'),
        ],
      ),
    );
  }

  Widget _buildDropdownButton(String value, ValueChanged<String?> onChanged, List<String> items) {
    return SizedBox(
      height: 50, // กำหนดความสูงของกรอบสีขาว
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return SizedBox(
      height: 50, // กำหนดความสูงของกรอบสีขาว
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: labelText,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:project_app/component/constant.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController diseaseController = TextEditingController();
  final TextEditingController allergyController = TextEditingController();
  final TextEditingController activityController = TextEditingController();
  int currentMonthIndex = 0;
  final List<String> months = ['มกราคม', 'กุมภาพันธ์', 'มีนาคม']; // Add more months as needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Jua',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: backgroundHead2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: backgroundPink),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalorieGraphCard(
                currentMonthIndex: currentMonthIndex,
                onMonthChanged: (index) {
                  setState(() {
                    currentMonthIndex = index;
                  });
                },
                months: months,
              ),
              const SizedBox(height: 20),
              ProfileInfoCard(
                onEdit: _editProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', nameController),
                _buildTextField('Gender', genderController),
                _buildTextField('Age', ageController),
                _buildTextField('Weight', weightController),
                _buildTextField('Height', heightController),
                _buildTextField('Disease', diseaseController),
                _buildTextField('Allergy', allergyController),
                _buildTextField('Activity', activityController),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Save the updated information
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class CalorieGraphCard extends StatelessWidget {
  final int currentMonthIndex;
  final ValueChanged<int> onMonthChanged;
  final List<String> months;

  CalorieGraphCard({
    required this.currentMonthIndex,
    required this.onMonthChanged,
    required this.months,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ปริมาณแคลอรี่เดือน ${months[currentMonthIndex]} 2567',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Placeholder for graph
          Container(
            height: 200,
            color: Colors.white,
            child: Center(child: Text('Graph Placeholder')),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: currentMonthIndex > 0
                    ? () => onMonthChanged(currentMonthIndex - 1)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: currentMonthIndex < months.length - 1
                    ? () => onMonthChanged(currentMonthIndex + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final VoidCallback onEdit;

  ProfileInfoCard({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10.0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'ชื่อ : ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProfileInfoRow(label: 'เพศ : ', value: ''),
          const SizedBox(height: 10),
          ProfileInfoRow(label: 'อายุ : ', value: ''),
          const SizedBox(height: 10),
          ProfileInfoRow(label: 'น้ำหนัก : ', value: ''),
          const SizedBox(height: 10),
          ProfileInfoRow(label: 'ส่วนสูง : ', value: ''),
          const SizedBox(height: 10),
          ProfileInfoRow(label: 'โรคที่เป็น : ', value: ''),
          const SizedBox(height: 10),
          ProfileInfoRow(label: 'อาหารที่แพ้ : ', value: ''),
          const SizedBox(height: 10),
          ProfileInfoRow(label: 'กิจกรรมที่ทำเป็นประจำ : ', value: ''),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Text(
                'BMI 22.5',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

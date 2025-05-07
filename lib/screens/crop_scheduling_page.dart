import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class CropSchedulingPage extends StatefulWidget {
  @override
  _CropSchedulingPageState createState() => _CropSchedulingPageState();
}

class _CropSchedulingPageState extends State<CropSchedulingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _landSizeController = TextEditingController();
  String _landUnit = 'Cents';
  String _cropType = 'Vegetable';
  String? _cropName;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _selectedState;
  String? _selectedDistrict;

  final List<String> _landUnits = ['Cents', 'Acres'];
  final Map<String, List<String>> _cropOptions = {
    'Vegetable': ['Tomato', 'Carrot', 'Potato', 'Cabbage', 'Spinach'],
    'Fruit': ['Mango', 'Banana', 'Apple', 'Grapes', 'Orange'],
    'Grain': ['Wheat', 'Rice', 'Corn', 'Barley', 'Millet'],
    'Herb': ['Mint', 'Basil', 'Coriander', 'Thyme', 'Oregano'],
    'Seed': ['Sunflower', 'Sesame', 'Pumpkin', 'Flax', 'Chia'],
    'Nut': ['Almond', 'Cashew', 'Walnut', 'Peanut', 'Pistachio'],
    'Pulse': ['Lentil', 'Chickpea', 'Pea', 'Kidney Bean', 'Black Gram']
  };

  // Define states and districts
  final Map<String, List<String>> _stateDistricts = {
    'Andhra Pradesh': [
      'Ananthapur',
      'Chittoor',
      'East Godavari',
      'Guntur',
      'Kadapa YSR',
      'Krishna',
      'Kurnool',
      'S.P.S. Nellore',
      'Srikakulam',
      'Visakhapatnam',
      'West Godavari'
    ],
    'Assam': [
      'Cachar',
      'Darrang',
      'Dibrugarh',
      'Goalpara',
      'Kamrup',
      'Karbi Anglong',
      'Lakhimpur',
      'Nagaon',
      'North Cachar Hil / Dima hasao',
      'Sibsagar'
    ],
    'Bihar': [
      'Bhagalpur',
      'Champaran',
      'Darbhanga',
      'Gaya',
      'Mungair',
      'Muzaffarpur',
      'Patna',
      'Purnea',
      'Saharsa',
      'Saran',
      'Shahabad (now part of Bhojpur district)'
    ],
    'Chhattisgarh': [
      'Bastar',
      'Bilaspur',
      'Durg',
      'Raigarh',
      'Raipur',
      'Surguja'
    ],
    'Gujarat': [
      'Ahmedabad',
      'Amreli',
      'Banaskantha',
      'Bharuch',
      'Bhavnagar',
      'Dangs',
      'Jamnagar',
      'Junagadh',
      'Kheda',
      'Kutch',
      'Mehsana',
      'Panchmahal',
      'Rajkot',
      'Sabarkantha',
      'Surat',
      'Surendranagar',
      'Vadodara / Baroda',
      'Valsad'
    ],
    'Haryana': [
      'Ambala',
      'Gurgaon',
      'Hissar',
      'Jind',
      'Karnal',
      'Mahendragarh / Narnaul',
      'Rohtak'
    ],
    'Himachal Pradesh': [
      'Bilashpur',
      'Chamba',
      'Kangra',
      'Kinnaur',
      'Kullu',
      'Lahul & Spiti',
      'Mandi',
      'Shimla',
      'Sirmaur',
      'Solan'
    ],
    'Jharkhand': [
      'Dhanbad',
      'Hazaribagh',
      'Palamau',
      'Ranchi',
      'Santhal Paragana / Dumka',
      'Singhbhum'
    ],
    'Karnataka': [
      'Bangalore',
      'Belgaum',
      'Bellary',
      'Bidar',
      'Bijapur / Vijayapura',
      'Chickmagalur',
      'Chitradurga',
      'Dakshina Kannada',
      'Dharwad',
      'Gulbarga / Kalaburagi',
      'Hassan',
      'Kodagu / Coorg',
      'Kolar',
      'Mandya',
      'Mysore',
      'Raichur',
      'Shimoge',
      'Tumkur',
      'Uttara Kannada'
    ],
    'Kerala': [
      'Alappuzha',
      'Eranakulam',
      'Kannur',
      'Kollam',
      'Kottayam',
      'Kozhikode',
      'Malappuram',
      'Palakkad',
      'Thiruvananthapuram',
      'Thrissur'
    ],
    'Madhya Pradesh': [
      'Balaghat',
      'Betul',
      'Bhind',
      'Chhatarpur',
      'Chhindwara',
      'Damoh',
      'Datia',
      'Dewas',
      'Dhar',
      'Guna',
      'Gwalior',
      'Hoshangabad',
      'Indore',
      'Jabalpur',
      'Jhabua',
      'Khandwa / East Nimar',
      'Khargone / West Nimar',
      'Mandla',
      'Mandsaur',
      'Morena',
      'Narsinghpur',
      'Panna',
      'Raisen',
      'Rajgarh',
      'Ratlam',
      'Rewa',
      'Sagar',
      'Satna',
      'Sehore',
      'Seoni / Shivani',
      'Shahdol',
      'Shajapur',
      'Shivpuri',
      'Sidhi',
      'Tikamgarh',
      'Ujjain',
      'Vidisha'
    ],
    'Maharashtra': [
      'Ahmednagar',
      'Akola',
      'Amarawati',
      'Aurangabad',
      'Beed',
      'Bhandara',
      'Bombay',
      'Buldhana',
      'Chandrapur',
      'Dhule',
      'Jalgaon',
      'Kolhapur',
      'Nagpur',
      'Nanded',
      'Nasik',
      'Osmanabad',
      'Parbhani',
      'Pune',
      'Raigad',
      'Ratnagiri',
      'Sangli',
      'Satara',
      'Solapur',
      'Thane',
      'Wardha',
      'Yeotmal'
    ],
    'Orissa': [
      'Balasore',
      'Bolangir',
      'Cuttack',
      'Dhenkanal',
      'Ganjam',
      'Kalahandi',
      'Keonjhar',
      'Koraput',
      'Mayurbhanja',
      'Phulbani ( Kandhamal )',
      'Puri',
      'Sambalpur',
      'Sundargarh'
    ],
    'Punjab': [
      'Amritsar',
      'Bhatinda',
      'Ferozpur',
      'Gurdaspur',
      'Hoshiarpur',
      'Jalandhar',
      'Kapurthala',
      'Ludhiana',
      'Patiala',
      'Roopnagar / Ropar',
      'Sangrur'
    ],
    'Rajasthan': [
      'Ajmer',
      'Alwar',
      'Banswara',
      'Barmer',
      'Bharatpur',
      'Bhilwara',
      'Bikaner',
      'Bundi',
      'Chittorgarh',
      'Churu',
      'Dungarpur',
      'Ganganagar',
      'Jaipur',
      'Jaisalmer',
      'Jalore',
      'Jhalawar',
      'Jhunjhunu',
      'Jodhpur',
      'Kota',
      'Nagaur',
      'Pali',
      'Sikar',
      'Sirohi',
      'Swami Madhopur',
      'Tonk',
      'Udaipur'
    ],
    'Tamil Nadu': [
      'Chengalpattu MGR / Kanchipuram',
      'Coimbatore',
      'Kanyakumari',
      'Madurai',
      'North Arcot / Vellore',
      'Ramananthapuram',
      'Salem',
      'South Arcot / Cuddalore',
      'Thanjavur',
      'The Nilgiris',
      'Thirunelveli',
      'Tiruchirapalli / Trichy'
    ],
    'Telangana': [
      'Adilabad',
      'Hyderabad',
      'Karimnagar',
      'Khammam',
      'Mahabubnagar',
      'Medak',
      'Nalgonda',
      'Nizamabad',
      'Warangal'
    ],
    'Uttar Pradesh': [
      'Agra',
      'Aligarh',
      'Allahabad',
      'Azamgarh',
      'Bahraich',
      'Ballia',
      'Banda',
      'Barabanki',
      'Bareilly',
      'Basti',
      'Bijnor',
      'Budaun',
      'Buland Shahar',
      'Deoria',
      'Etah',
      'Etawah',
      'Faizabad',
      'Farrukhabad',
      'Fatehpur',
      'Ghazipur',
      'Gonda',
      'Gorakhpur',
      'Hamirpur',
      'Hardoi',
      'Jalaun',
      'Jaunpur',
      'Jhansi',
      'Kanpur',
      'Kheri',
      'Lucknow',
      'Mainpuri',
      'Mathura',
      'Meerut',
      'Mirzpur',
      'Moradabad',
      'Muzaffarnagar',
      'Pilibhit',
      'Pratapgarh',
      'Rae-Bareily',
      'Rampur',
      'Saharanpur',
      'Shahjahanpur',
      'Sitapur',
      'Sultanpur',
      'Unnao',
      'Varanasi'
    ],
    'Uttarakhand': [
      'Almorah',
      'Chamoli',
      'Dehradun',
      'Garhwal',
      'Nainital',
      'Pithorgarh',
      'Tehri Garhwal',
      'Uttar Kashi'
    ],
    'West Bengal': [
      '24 Parganas',
      'Bankura',
      'Birbhum',
      'Burdwan',
      'Cooch Behar',
      'Darjeeling',
      'Hooghly',
      'Howrah',
      'Jalpaiguri',
      'Malda',
      'Midnapur',
      'Murshidabad',
      'Nadia',
      'Purulia',
      'West Dinajpur'
    ],
  };

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null ||
        _cropName == null ||
        _selectedState == null ||
        _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select dates')),
      );
      return;
    }

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to schedule a crop')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduleData = {
        'user_id': userId,
        'land_size': double.parse(_landSizeController.text),
        'land_unit': _landUnit,
        'crop_type': _cropType,
        'crop_name': _cropName,
        'state': _selectedState,
        'district': _selectedDistrict,
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
      };

      await supabase.from('crop_scheduling').insert(scheduleData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule saved successfully!')),
      );

      Navigator.pop(context);

      setState(() {
        _formKey.currentState!.reset();
        _landSizeController.clear();
        _startDate = null;
        _endDate = null;
        _cropName = null;
        _selectedState = null;
        _selectedDistrict = null;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving schedule: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Scheduling", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000a00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Land Unit',
                  border: OutlineInputBorder(),
                ),
                value: _landUnit,
                items: _landUnits.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _landUnit = value!);
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _landSizeController,
                decoration: InputDecoration(
                  labelText: 'Land Size',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter land size';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Crop Type',
                  border: OutlineInputBorder(),
                ),
                value: _cropType,
                items: _cropOptions.keys.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _cropType = value!;
                    _cropName = null;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Crop Name',
                  border: OutlineInputBorder(),
                ),
                value: _cropName,
                items: _cropOptions[_cropType]!.map((crop) {
                  return DropdownMenuItem<String>(
                    value: crop,
                    child: Text(crop),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _cropName = value);
                },
                validator: (value) =>
                value == null ? 'Please select a crop name' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                value: _selectedState,
                items: _stateDistricts.keys.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedDistrict =
                    null; // Reset district when state changes
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDistrict,
                items: _selectedState == null
                    ? []
                    : _stateDistricts[_selectedState]!.map((district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                },
                validator: (value) {
                  if (value == null && _selectedState != null) {
                    return 'Please select a district';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text("Start Date",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              ListTile(
                title: Text(
                  _startDate == null
                      ? "Select Start Date"
                      : DateFormat('yyyy-MM-dd').format(_startDate!),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              SizedBox(height: 8),
              Text("End Date",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              ListTile(
                title: Text(
                  _endDate == null
                      ? "Select End Date"
                      : DateFormat('yyyy-MM-dd').format(_endDate!),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveSchedule,
                  child: Text('Save Schedule',
                      style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff065a00),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

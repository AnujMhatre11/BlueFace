import 'dart:convert';
import 'package:BlueFace/Model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../FacultySide/FacultyHomepage.dart';
import '../StudentSide/StudentHomepage.dart';




class Services {
  final String url1 = "http://192.168.133.38:4000";

  Future<bool> loginStudent(BuildContext context, String email,
      String password) async {
    var url = Uri.parse(
        url1 + '/userss/loginstudent'); // Replace with your server URL
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email.toString().trim(),
          "password": password.toString().trim(),
        }),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          var studentData = responseData['data'];
          StudentLogin student = StudentLogin.fromJson(studentData);
          print(student.name);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => StudentLoggedIn(student: student,)),
          );
          return true;
        } else {
          Fluttertoast.showToast(
            msg: "Login failed. Please check your credentials.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Login failed. Please check your credentials.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

    } catch (e) {
      print('Error during login: $e');
      Fluttertoast.showToast(
        msg: "An error occurred. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    return false;
  }

  Future<void> loginFaculty(BuildContext context, String email, String password) async {
    var url = Uri.parse(url1 + '/userss/login');
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email.toString().trim(),
          "password": password.toString().trim(),
        }),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          var facultyData = responseData['data'];
          print("Connected");
          FacultyLogin faculty = FacultyLogin.fromJson(facultyData);
          print(faculty.Faculty_id);
          print(faculty.Subjects);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FacultyLoggedIn(faculty: faculty)),
          );
        } else {
          _showToast("Login failed. Please check your credentials.");
        }
      } else {
        _showToast("Login failed. Please check your credentials.");
      }
    } catch (e) {
      print('Error during login: $e');
      _showToast("An error occurred. Please try again.");
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> markAttendance() async {
    String url = '${url1}/userss/takeAttendance';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{

      }),
    );

    if (response.statusCode == 200) {
      print('Attendance recorded successfully');
    } else {
      print('Failed to record attendance');
      // showSnackbar('Failed to record attendance');
    }
  }

  Future<void> fetchStudents(List<StudentLogin> studentsList) async {
    studentsList.clear();

    try {
      final res = await http.get(Uri.parse(url1+"/userss/students"));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success'] == true) {
          List<dynamic> studentData = data['data'];
          studentData.forEach((value) {
            studentsList.add(
              StudentLogin(
                  name: value['student_name'],
                  PRN: value['PRN'],
                  Semester: value['Semester'],
                  Branch: value['Branch'],
                  // Division: value['Division'],
                  // Batch: value['Batch'],
                  isPresent: false
              ),
            );
          });
          // setState(() {});
        } else {
          throw Exception('Failed to fetch students data');
        }
      } else {
        throw Exception('Failed to load students data, status code: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching students data: $e');
      throw Exception('Failed to fetch students data');
    }
  }

  Future<void> commitAttendance(List<StudentList> studentslist,String branch, String semester, String subject,String localDateTime) async {
    String tableName = '${branch}_${semester}_${subject}';
    List<Map<String, dynamic>> attendanceData = studentslist.map((student) {
      return {
        'PRN': student.PRN,
        'status': student.isPresent ? 'Present' : 'Absent',
      };
    }).toList();

    try {
      final res = await http.post(
        Uri.parse(url1+"/userss/attendance/commit"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tableName': tableName,
          'localDateTime': localDateTime
          // 'attendanceData': attendanceData,
        }),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['success'] == true) {
        } else {
          throw Exception('Failed to commit attendance data');
        }
      } else {
        throw Exception('Failed to commit attendance data, status code: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error committing attendance data: $e');
    }
  }
  Future<void> fetchConnectedStudents(List<ConnectedStudent> connectedStudents) async {
    connectedStudents.clear();

    try {
      final res = await http.get(Uri.parse(url1+"/userss/connectattendance"));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status_code'] == 200) {
          List<dynamic> connectedData = data['connect_students'];
          connectedData.forEach((value) {
            connectedStudents.add(
              ConnectedStudent(
                studentName: value['studentName'],
                semester1: value['semester'],
                branch: value['branch'],
                PRN: value['PRN'],
                datetime: DateTime.parse(value['date']),
              ),
            );
          });
        } else {
          throw Exception('Failed to fetch connected students data');
        }
      } else {
        throw Exception('Failed to load connected students data, status code: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching connected students data: $e');
      throw Exception('Failed to fetch connected students data');
    }
  }
  Future<void> getSubjects(FacultyLogin faculty) async {
    try {
      final res = await http.get(Uri.parse(url1+"/userss/getSubjects"));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status_code'] == 200) {
          List<dynamic> connectedData = data['connect_students'];
          connectedData.forEach((value) {
            faculty.Subjects.add(value);
          });
        } else {
          throw Exception('Failed to fetch connected students data');
        }
      } else {
        throw Exception('Failed to load connected students data, status code: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching connected students data: $e');
      throw Exception('Failed to fetch connected students data');
    }
  }
}
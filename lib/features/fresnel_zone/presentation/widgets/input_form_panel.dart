import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fresnel_zone_app/features/fresnel_zone/model/fresnel_zone_model.dart';
import 'package:provider/provider.dart';

class InputFormPanel extends StatefulWidget {
  const InputFormPanel({super.key});

  @override
  State<InputFormPanel> createState() => _InputFormPanelState();
}

class _InputFormPanelState extends State<InputFormPanel> {
  final _height1TextController = TextEditingController(text: '1');
  final _height2TextController = TextEditingController(text: '1');
  final _frequencyTextController = TextEditingController(text: '30');
  final _pathTextController = TextEditingController();

  String? _pathToDirectory;
  late Future<List<String>?> filenames;

  TextEditingController get height1TextController => _height1TextController;
  TextEditingController get height2TextController => _height2TextController;
  TextEditingController get frequencyTextController => _frequencyTextController;
  TextEditingController get pathTextController => _pathTextController;

  String? validateHeight(String value) {
    if (value.isEmpty) {
      return "Введите число от 1 до 10000";
    }
    if (double.parse(value) < 1 || double.parse(value) > 10000) {
      return "Число должно быть от 1 до 10000";
    }
    return null;
  }

  String? validateFrequency(String value) {
    if (value.isEmpty) {
      return "Введите число от 30 до 6000";
    }
    if (double.parse(value) < 30 || double.parse(value) > 6000) {
      return "Число должно быть от 30 до 6000";
    }
    return null;
  }

  // Future<List<String>?> getFilenamesInDirectory(String pathToDirectory) async {
  //   if (await Directory(pathToDirectory).exists() == false) {
  //     return null;
  //   }
  //   Directory dir = Directory(pathToDirectory);
  //   List<FileSystemEntity> entities = dir.listSync();
  //   List<File> files = entities.whereType<File>().toList();
  //   List<String> filePaths = files.map((e) => e.path).toList();
  //   return filePaths;
  // }

  void getFilenamesInDirectory(String pathToDirectory) async {
    if (await Directory(pathToDirectory).exists() == false) {
      filenames = Future(() => null);
      return;
    }
    Directory dir = Directory(pathToDirectory);
    List<FileSystemEntity> entities = dir.listSync();
    List<File> files = entities.whereType<File>().toList();
    List<String> filePaths = files.map((e) => e.path).toList();
    filenames = Future(() => filePaths);
  }

  @override
  void initState() {
    super.initState();
    getFilenamesInDirectory('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 194, 194, 194),
          width: 2,
        ),
        color: const Color.fromARGB(255, 157, 215, 241),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Consumer<FresnelZoneModel>(
                      builder: (context, model, child) {
                        return TextFormField(
                          controller: height1TextController,
                          decoration: InputDecoration(
                            labelText: 'Высота 1 (м)',
                            errorText: validateHeight(height1TextController.text),
                          ),
                          inputFormatters: [DecimalNumberFormatter()],
                          keyboardType: TextInputType.number,
                          onEditingComplete: () {
                            if (height1TextController.text.isEmpty) {
                              setState(() {});
                              return;
                            }
                            if (validateHeight(height1TextController.text) != null) {
                              setState(() {});
                              return;
                            }
                            model.setHeight1(double.parse(height1TextController.text));
                            setState(() {});
                          },
                        );
                      }
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Consumer<FresnelZoneModel>(
                      builder: (context, model, child) {
                        return TextFormField(
                          controller: height2TextController,
                          decoration: InputDecoration(
                            labelText: 'Высота 2 (м)',
                            errorText: validateHeight(height2TextController.text),
                          ),
                          inputFormatters: [DecimalNumberFormatter()],
                          keyboardType: TextInputType.number,
                          onEditingComplete: () {
                            if (height2TextController.text.isEmpty) {
                              setState(() {});
                              return;
                            }
                            if (validateHeight(height2TextController.text) != null) {
                              setState(() {});
                              return;
                            }
                            model.setHeight2(double.parse(height2TextController.text));
                            setState(() {});
                          },
                        );
                      }
                    )
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Consumer<FresnelZoneModel>(
                      builder: (context, model, child) {
                        return TextFormField(
                          controller: frequencyTextController,
                          decoration: InputDecoration(
                            labelText: 'Частота (МГц)',
                            errorText: validateFrequency(frequencyTextController.text),
                          ),
                          inputFormatters: [DecimalNumberFormatter()],
                          keyboardType: TextInputType.number,
                          onEditingComplete: () {
                            if (frequencyTextController.text.isEmpty) {
                              setState(() {});
                              return;
                            }
                            if (validateFrequency(frequencyTextController.text) != null) {
                              setState(() {});
                              return;
                            }
                            model.setFrequency(double.parse(frequencyTextController.text) * 1000000);
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: TextFormField(
                            controller: pathTextController,
                            decoration: InputDecoration(
                              labelText: 'Рабочий каталог',
                            ),
                            onEditingComplete: () {
                              setState(() {
                                _pathToDirectory = pathTextController.text;
                                if (_pathToDirectory != null) {
                                  getFilenamesInDirectory(_pathToDirectory!);
                                }
                              });
                            }
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: RepaintBoundary(
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await FilePicker.platform.getDirectoryPath();
                                if (result == null) return;
                                setState(() {
                                  _pathToDirectory = result;
                                  pathTextController.text = result;
                                  getFilenamesInDirectory(result);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Text('...'),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_pathToDirectory == null) {
                        return Container(
                          width: 300,
                          padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text('Укажите рабочую директорию')
                          )
                        );
                      } else {
                        return FutureBuilder<List<String>?>(
                          future: filenames,
                          builder:(context, snapshot) {
                            final filePaths = snapshot.data;
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox(
                                width: 300,
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (filePaths == null) {
                              return SizedBox(
                                width: 300,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text('Директория не существует')
                                ),
                              );
                            }
                            if (filePaths.isEmpty) {
                              return SizedBox(
                                width: 300,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text('Файлы не найдены')
                                ),
                              );
                            } else {
                              return ListView.builder(
                                itemCount: filePaths.length,
                                itemBuilder: (context, index) {
                                  final path = filePaths[index];
                                  return RepaintBoundary(
                                    child: SizedBox(
                                      height: 40,
                                      width: 290,
                                      child: Consumer<FresnelZoneModel>(
                                        builder: (context, model, child) {
                                          return OutlinedButton(
                                            onPressed: () {
                                              model.setFilePath(path);
                                            },
                                            style: ButtonStyle(splashFactory: NoSplash.splashFactory),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                path,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DecimalNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow empty input.
    if (newValue.text == '') return newValue;

    // Regex: can start with zero or more digits, maybe followed by a decimal
    // point, followed by zero, one, two, or three digits.
    return RegExp('^\\d*\\.?\\d?\\d?\\d?\\d?\\d?\\d?\$').hasMatch(newValue.text)
        ? newValue
        : oldValue;
  }
}
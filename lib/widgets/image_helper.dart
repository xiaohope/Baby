import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

/// 判断字符串是否为base64编码的图片（纯base64字符+长度>500）
bool isBase64Image(String s) => s.length > 500 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(s);

/// 通用图片组件：支持本地文件路径、http URL、base64字符串
Widget buildImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  Widget image;
  if (isBase64Image(path)) {
    image = Image.memory(base64Decode(path), fit: fit, width: width, height: height);
  } else if (path.startsWith('http')) {
    image = Image.network(path, fit: fit, width: width, height: height,
      errorBuilder: (_, __, ___) => _placeholder());
  } else if (path.startsWith('/uploads/')) {
    image = Image.network('http://8.138.224.195$path', fit: fit, width: width, height: height,
      errorBuilder: (_, __, ___) => _placeholder());
  } else {
    image = Image.file(File(path), fit: fit, width: width, height: height,
      errorBuilder: (_, __, ___) => _placeholder());
  }
  return image;
}

Widget _placeholder() => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey));

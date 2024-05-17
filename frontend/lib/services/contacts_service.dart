// lib/services/contacts_service.dart

import 'package:contacts_service/contacts_service.dart';

// 연락처를 처리하는 클래스를 정의
class ContactsHelper {
  // 주어진 전화번호에 일치하는 첫 번째 연락처를 가져오는 함수
  static Future<Contact?> getContactForPhone(String phoneNumber) async {
    var contacts = await ContactsService.getContacts(query: phoneNumber, withThumbnails: true, photoHighResolution: true);
    for (var contact in contacts) {
      if (contact.phones != null && contact.phones!.any((item) => cleanPhoneNumber(item.value!) == cleanPhoneNumber(phoneNumber))) {
        return contact;
      }
    }
    return null;
  }

  // 전화번호에서 불필요한 문자 제거
  static String cleanPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null) return '';
    return phoneNumber.replaceAll(RegExp(r'[^+\d]'), '');
  }

  // 전화번호에 따라 연락처를 가져오는 비동기 함수
  static Future<List<Contact>> getContactsForPhone(String phoneNumber) async {
    // 연락처 목록 가져오기
    List<Contact> contacts = await ContactsService.getContacts(
      // 썸네일 및 고해상도 사진은 일단 포함하지 않도록 설정
      withThumbnails: false,
      photoHighResolution: false,
    );

    // 주어진 전화번호에 해당하는 연락처만 필터링해서 반환
    return contacts.where((contact) {
      return contact.phones?.any((phone) {
        // 연락처의 전화번호에서 숫자와 "+" 이외의 문자는 제거하고, 주어진 전화번호와 일치하는지 확인
        // +는 국제전화 번호 때문에 놔둔건데 삭제해도 될 듯?
        return phone.value?.replaceAll(RegExp(r'[^\d+]'), '') == phoneNumber;
      }) ?? false;
    }).toList();
  }
}
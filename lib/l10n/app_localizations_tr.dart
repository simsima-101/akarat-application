// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Emlak';

  @override
  String get search => 'Ara';

  @override
  String get properties => 'Emlaklar';

  @override
  String get hello => 'Merhaba';

  @override
  String get language => 'Dil';

  @override
  String get myAccount => 'Hesabım';

  @override
  String get newProjectsTitle => 'Yeni Projeler';

  @override
  String get newProjectsSubtitle =>
      'Dubai\'deki yeni inşaat projelerini keşfedin ve BAE emlak piyasasına yatırım yapmak için bilmeniz gereken her şeyi öğrenin';

  @override
  String get latestProjectsTitle => 'Dubai\'deki En Son Projeler';

  @override
  String get errorLoadingProjects => 'Projeler yüklenemedi.';

  @override
  String get noProjectsFound => 'Hiç mülk bulunamadı.';

  @override
  String get agent => 'Acenta';

  @override
  String get priceOnRequest => 'Fiyat bilgisi için iletişime geçin';

  @override
  String get locationNotAvailable => 'Konum mevcut değil';

  @override
  String get call => 'Ara';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get agentLabel => 'ACENTA';

  @override
  String get noTitle => 'Başlık yok';

  @override
  String get currencyAed => 'AED';

  @override
  String get projectInformation => 'Proje Bilgileri';

  @override
  String get projectDetail => 'Proje Detayı';

  @override
  String get noData => 'Veri yok';

  @override
  String get loginRequired => 'Giriş Yapılması Gerekiyor';

  @override
  String get loginToAccessFavorites =>
      'Favorilere erişmek için lütfen giriş yapın.';

  @override
  String get cancel => 'İptal';

  @override
  String get login => 'Giriş Yap';

  @override
  String get welcomeLoginSignUp => 'Hoş geldiniz! Giriş Yap / Kayıt Ol';

  @override
  String get myProfile => 'Profilim';

  @override
  String get findMyAgent => 'Acentemi Bul';

  @override
  String get favorites => 'Favoriler';

  @override
  String get savedAlerts => 'Kaydedilen Uyarılar';

  @override
  String get contactedProperties => 'İletişime Geçilen İlanlar';

  @override
  String get aboutUs => 'Hakkımızda';

  @override
  String get support => 'Destek';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get termsAndConditions => 'Şartlar ve Koşullar';

  @override
  String get rateUs => 'Bizi Değerlendir';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirmationTitle =>
      'Çıkış yapmak istediğinize emin misiniz?';

  @override
  String get loginRequiredTitle => 'Giriş Gereklidir';

  @override
  String get loginToAccessSavedAlerts =>
      'Kaydedilen uyarılara erişmek için lütfen giriş yapın.';

  @override
  String get loginToViewContacted =>
      'İletişime geçilen ilanları görmek için lütfen giriş yapın.';

  @override
  String get notLoggedInForAction => 'Giriş yapmadınız';

  @override
  String get accountDeletedSuccessfully => 'Hesap başarıyla silindi';

  @override
  String get deletionFailed => 'Silme işlemi başarısız oldu';

  @override
  String get homeSearchLocationHint => 'Bir mahalle, bölge veya şehir ara';

  @override
  String get homePropertyForRent => 'Kiralık Emlak';

  @override
  String get homePropertyForSale => 'Satılık Emlak';

  @override
  String get homeOffPlanProperties => 'Planlanan Projeler';

  @override
  String get homeCommercial => 'Ticari';

  @override
  String get homeVilla => 'Villalar';

  @override
  String get homeApartment => 'Daireler';

  @override
  String get homeDiscoverUaeRealEstate =>
      'BAE emlak piyasası hakkında daha fazlasını keşfedin';

  @override
  String get homeSortNewest => 'En Yeniler';

  @override
  String get homeSortFeatured => 'Öne Çıkanlar';

  @override
  String get homeSortPriceLow => 'Fiyat (Düşük)';

  @override
  String get homeSortPriceHigh => 'Fiyat (Yüksek)';

  @override
  String get loginToEditProfile =>
      'Profilinizi düzenlemek için lütfen giriş yapın.';

  @override
  String get myAccountSupportTitle => 'Bize Ulaşın';

  @override
  String get myAccountSupportSubTitle => 'Bize her şeyi sorabilirsiniz?';

  @override
  String get myAccountSupportNameLabel => 'Ad';

  @override
  String get myAccountSupportEmailLabel => 'E-posta Adresi';

  @override
  String get myAccountSupportPhoneLabel => 'Telefon Numarası';

  @override
  String get myAccountSupportSubjectLabel => 'Konu';

  @override
  String get myAccountSupportMessageLabel => 'Mesaj';

  @override
  String get myAccountSupportSubmitButtonText => 'Gönder';

  @override
  String get myAccountSupportValidationEnterText => 'Lütfen girin';

  @override
  String get myAccountSupportValidationEnterPhone =>
      'Lütfen telefon numarası girin';

  @override
  String get myAccountSupportValidationPhoneDigitsOnly =>
      'Telefon numarası yalnızca rakam içermelidir';

  @override
  String myAccountSupportValidationPhoneLength(Object country, Object length) {
    return 'Telefon numarası $country için $length haneli olmalıdır';
  }

  @override
  String myAccountSupportValidationRequired(Object label) {
    return 'Lütfen $label girin';
  }

  @override
  String get myAccountSupportValidationEmailRequired => 'Lütfen E-posta girin';

  @override
  String get myAccountSupportValidationEmailInvalid =>
      'Lütfen geçerli bir e-posta girin';
}

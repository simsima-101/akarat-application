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
  String get loginToEditProfile =>
      'Profilinizi düzenlemek için lütfen giriş yapın.';

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

  @override
  String get myAccountTermsAndConditionsAppBarTitle => 'Şartlar ve Koşullar';

  @override
  String get findAgentTitle => 'Acentemi Bul';

  @override
  String get agentsTab => 'Acentalar';

  @override
  String get agencyTab => 'Emlak Ofisleri';

  @override
  String get searchAgentHint => 'Konum veya acenta adı girin';

  @override
  String get searchAgencyHint => 'Konum veya emlak ofisi adı girin';

  @override
  String get featuredAgents => 'Öne Çıkan Acentalar';

  @override
  String get featuredAgencies => 'Öne Çıkan Emlak Ofisleri';

  @override
  String get featuredAgentsDescription =>
      'Yüksek yanıt oranları ve gerçek ilanlarla kanıtlanmış geçmişe sahip acentaları keşfedin.';

  @override
  String get featuredAgenciesDescription =>
      'Yüksek yanıt oranları ve gerçek ilanlarla kanıtlanmış geçmişe sahip emlak ofislerini keşfedin.';

  @override
  String get noAgentsFound => 'Acenta bulunamadı';

  @override
  String get noAgenciesFound => 'Emlak ofisi bulunamadı';

  @override
  String get noResults => 'Sonuç Yok';

  @override
  String get resetFilters => 'Sıfırla';

  @override
  String get failedToLoadNationalities => 'Uyruklar yüklenemedi';

  @override
  String get failedToLoadLanguages => 'Diller yüklenemedi';

  @override
  String get agentAboutTitle => 'Hakkında';

  @override
  String get agentDescriptionLabel => 'Açıklama';

  @override
  String get agentNoDescription => 'Açıklama mevcut değil';

  @override
  String get agentExpertiseLabel => 'Uzmanlık';

  @override
  String get agentServiceAreasLabel => 'Hizmet Alanları';

  @override
  String get agentLanguagesLabel => 'Dil(ler)';

  @override
  String get agentExperienceLabel => 'Deneyim';

  @override
  String get agentExperienceYears => 'Yıl';

  @override
  String get agentBrnLabel => 'BRN';

  @override
  String get agentReviewsTitle => 'Yorumlar';

  @override
  String get comingSoonTitle => 'Yakında';

  @override
  String get agentReviewsComingSoonMessage =>
      'Acente yorumları yakında burada olacak';

  @override
  String get agentContactEmail => 'E-posta';

  @override
  String get agentContactCall => 'Ara';

  @override
  String get agentContactWhatsApp => 'WhatsApp';

  @override
  String get propertiesTab => 'İlanlar';

  @override
  String get reviewTab => 'Yorumlar';

  @override
  String get agentSpeaksLabel => 'Konuştuğu diller: ';

  @override
  String agentSaleTag(Object count) {
    return '$count Satılık';
  }

  @override
  String agentRentTag(Object count) {
    return '$count Kiralık';
  }

  @override
  String get notAvailable => 'Mevcut Değil';

  @override
  String agentPropertiesCount(Object count) {
    return '$count İlan';
  }

  @override
  String propertiesCountLabel(Object count) {
    return '$count Mülk';
  }

  @override
  String get registerTitle => 'Hesap Oluştur';

  @override
  String get continueWithGoogle => 'Google ile Devam Et';

  @override
  String get or => 'VEYA';

  @override
  String get firstNameHint => 'Ad';

  @override
  String get lastNameHint => 'Soyad';

  @override
  String get emailHint => 'E-posta';

  @override
  String get phoneHint => 'Telefon';

  @override
  String get passwordHint => 'Şifre';

  @override
  String get confirmPasswordHint => 'Şifreyi Onayla';

  @override
  String get atLeast8Characters => 'En az 8 karakter';

  @override
  String get oneUppercaseLetter => 'Bir büyük harf';

  @override
  String get oneNumber => 'Bir rakam';

  @override
  String get oneSpecialCharacter => 'Bir özel karakter';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get bySigningUpAgreeTo => 'Kaydolarak kabul ediyorum ';

  @override
  String get and => ' ve ';

  @override
  String get alreadyHaveAccount => 'Zaten bir hesabınız var mı? ';

  @override
  String get loginHere => 'Buradan Giriş Yapın';

  @override
  String get searchCountryHint => 'Ülke ara';

  @override
  String get errorFirstNameRequired => 'Lütfen adınızı girin';

  @override
  String get errorLastNameRequired => 'Lütfen soyadınızı girin';

  @override
  String get errorEmailRequired => 'Lütfen e-posta adresinizi girin';

  @override
  String get errorInvalidEmail => 'Geçersiz e-posta';

  @override
  String get errorPhoneRequired => 'Lütfen telefon numaranızı girin';

  @override
  String get errorInvalidPhoneDigits => 'Geçerli bir numara girin';

  @override
  String errorPhoneLength(Object length, Object countryCode) {
    return 'Telefon numarası $countryCode için $length hane olmalıdır';
  }

  @override
  String get errorPasswordRequired => 'Lütfen şifrenizi girin';

  @override
  String get errorPasswordRequirements => 'Şifre gereksinimleri karşılamıyor';

  @override
  String get errorConfirmPasswordRequired => 'Lütfen şifreyi onaylayın';

  @override
  String get errorPasswordsNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get otpSentMessage =>
      'OTP gönderildi. Lütfen e-postanızı kontrol edin.';

  @override
  String get registrationTimedOut =>
      'Kayıt zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get emailAlreadyRegistered =>
      'Bu e-posta zaten kayıtlı. Lütfen giriş yapın veya Şifremi Unuttum kullanın.';

  @override
  String get tooManyAttempts =>
      'Çok fazla deneme. Lütfen bir dakika bekleyip tekrar deneyin.';

  @override
  String get googleSignInNotSupported =>
      'Bu platform Google ile girişi desteklemiyor';

  @override
  String get firebaseUserNullAfterSignIn =>
      'Giriş başarısız. Kullanıcı hesabı oluşturulmadı.';

  @override
  String get failedToGetFirebaseIdToken =>
      'Kimlik doğrulama token\'ı alınamadı.';

  @override
  String get accountDeletedOrInactiveContactSupport =>
      'Bu hesap silinmiş veya devre dışı bırakılmış.\nYeniden etkinleştirmek için lütfen destek ekibiyle iletişime geçin ya da farklı bir e-posta kullanın';

  @override
  String get accountDeletedOrTokenMissing =>
      'Bu hesap silinmiş veya token eksik.';

  @override
  String get nonJsonFromLoginGoogle =>
      'Sunucudan geçersiz yanıt alındı. Lütfen daha sonra tekrar deneyin.';



  @override
  String get myAccountTermsSectionIntroductionTitle => 'Giriş';

  @override
  String get myAccountTermsSectionIntroductionContent =>
      'Akarat\'a hoş geldiniz (\"Platform\"). Bu Şartlar ve Koşullar (\"Şartlar\"), Akarat ile web sitemize, mobil uygulamamıza, dijital çözümlerimize veya ilgili herhangi bir araç ve işlevselliğe (topluca \"Hizmetler\") erişen, kullanan veya bunlarla etkileşime giren herhangi bir birey veya kuruluş arasında yasal olarak bağlayıcı bir anlaşma oluşturur. Bu Şartlar, ziyaretçiler, kayıtlı üyeler, reklam verenler, lisanslı acenteler, geliştiriciler ve Platform\'a erişen veya kullanan diğer tüm taraflar dahil olmak üzere tüm kullanıcı kategorilerine uygulanır.\n\nPlatform\'un herhangi bir bileşenini kullanarak veya erişerek, bu Şartları ve Gizlilik Politikamızı okuduğunuzu, anladığınızı ve bunlara uymayı kabul ettiğinizi beyan etmiş olursunuz. Bu belgede yer alan herhangi bir hükme katılmıyorsanız, Platform\'u ve ilgili tüm Hizmetleri derhal kullanmayı bırakmalısınız.';

  @override
  String get myAccountTermsSectionWhoWeAreTitle => '1. Biz Kimiz';

  @override
  String get myAccountTermsWhoWeAreCompany =>
      'Platform, Birleşik Arap Emirlikleri\'nde (BAE) yasal olarak kayıtlı bir kuruluş olan EMLAK BULUCU PORTAL LLC tarafından sahip olunmakta ve işletilmektedir.';

  @override
  String get myAccountTermsWhoWeAreOffice =>
      'Kayıtlı Ofis: Westburry Ofis Kulesi, 23. Kat, Ofis No. 2303, Business Bay, Dubai, BAE\nE-posta: info@akarat.com';

  @override
  String get myAccountTermsWhoWeArePronouns =>
      '\"Biz\", \"bize\" veya \"bizim\" ifadeleri Platform işletmecisi olan Akarat\'ı ifade eder.';

  @override
  String get myAccountTermsSectionDefinitionsTitle => '2. Tanımlar';

  @override
  String get myAccountTermsDefinitionAdvertiser =>
      'Reklam Veren: Platformda mülk ilanları yayınlayarak mülkleri tanıtmak, pazarlamak veya satmak amacıyla hareket eden herhangi bir birey, işletme veya kuruluş.';

  @override
  String get myAccountTermsDefinitionAgent =>
      'Acente: Mülkleri listelemek veya pazarlamak için yetkili lisanslı gayrimenkul uzmanı, aracı veya ajans.';

  @override
  String get myAccountTermsDefinitionContent =>
      'İçerik: Platforma yüklenen veya gönderilen tüm materyaller; metin, resim, video, belge, grafik ve diğer medya dahil.';

  @override
  String get myAccountTermsDefinitionListing =>
      'İlan: Platformda yayınlanan herhangi bir mülk reklamı, tanıtım girişi veya gönderi; ilgili tüm detaylar ve medya dahil.';

  @override
  String get myAccountTermsDefinitionUser =>
      'Kullanıcı / Siz: Platforma veya Hizmetlerine erişen, gezinen veya bunlarla etkileşime giren herhangi bir kişi, şirket veya kuruluş.';

  @override
  String get myAccountTermsDefinitionServices =>
      'Hizmetler: Akarat tarafından Platform üzerinden sunulan özellikler, araçlar, işlevler ve çözümlerin tamamı.';

  @override
  String get myAccountTermsSectionAcceptanceTitle => '3. Şartların Kabulü';

  @override
  String get myAccountTermsAcceptanceMain =>
      'Platforma erişerek veya kullanarak, bu Şartları okuduğunuzu, anladığınızı ve bunlara bağlı kalmayı açıkça kabul ettiğinizi beyan edersiniz. Platformu kullanmanız, burada belirtilen tüm yükümlülükleri kabul ettiğiniz anlamına gelir.';

  @override
  String get myAccountTermsAcceptanceNotAllowed =>
      'Aşağıdaki durumlardan herhangi biri geçerliyse Platformu kullanamazsınız:';

  @override
  String get myAccountTermsAcceptanceConditions =>
      '• 18 yaşından küçükseniz.\n• Yargı bölgeniz dijital gayrimenkul pazarlarına erişimi yasaklamaktaysa.\n• İlan verme, reklam yapma veya gayrimenkul ilanlarıyla etkileşimde bulunma için yasal veya uygunluk şartlarını karşılamıyorsanız.';

  @override
  String get myAccountTermsAcceptanceUpdates =>
      'Akarat, bu Şartları herhangi bir zamanda önceden haber vermeksizin değiştirme, düzeltme veya güncelleme hakkını saklı tutar. Güncellemeler yayınlandığı anda yürürlüğe girer. Değişikliklerden sonra Platformu kullanmaya devam etmeniz, revize edilen Şartları kabul ettiğiniz anlamına gelir.';

  @override
  String get myAccountTermsSectionScopeTitle => '4. Kullanım Kapsamı';

  @override
  String get myAccountTermsScopeIntro =>
      'Kullanıcılar Platformu profesyonel, etik ve yürürlükteki tüm yasalara uygun şekilde kullanmalıdır. Aşağıdaki eylemler kesinlikle yasaktır:';

  @override
  String get myAccountTermsScopeProhibited =>
      '• Yasadışı, yanıltıcı, hileli veya izinsiz telif hakkıyla korunan materyal yüklemek.\n• Platform verilerini ticari amaçla kazımak, kopyalamak veya çıkarmak.\n• Yanlış, tekrarlanan veya mevcut olmayan mülk ilanları yayınlamak.\n• Otomatik araçlar, botlar veya scriptler kullanarak Platforma erişmek veya etkileşimde bulunmak.\n• Platformun güvenliğini veya işleyişini zarar vermek, devre dışı bırakmak, aşırı yüklemek veya müdahale etmek.';

  @override
  String get myAccountTermsScopeConsequence =>
      'Kötüye kullanım, anında askıya alma, hesap kapatma, içerik kaldırma veya yasal işlemle sonuçlanabilir.';

  @override
  String get myAccountTermsSectionRegistrationTitle => '5. Hesap Kaydı';

  @override
  String get myAccountTermsRegistrationIntro =>
      'Bazı Hizmetler kullanıcı kaydı gerektirir. Doğru, eksiksiz ve güncel bilgi sağlamalısınız. Kullanıcılar şunlardan sorumludur:';

  @override
  String get myAccountTermsRegistrationDuties =>
      '• Giriş bilgilerini koruma\n• Yetkisiz erişimi önleme\n• Hesapları altında gerçekleştirilen tüm faaliyetler';

  @override
  String get myAccountTermsRegistrationNoLiability =>
      'Akarat, ihmal veya yetkisiz erişimden kaynaklanan kayıplardan sorumlu değildir.';

  @override
  String get myAccountTermsSectionAdvertiserAgentTitle =>
      '6. İlan Veren ve Acente Yükümlülükleri';

  @override
  String get myAccountTermsAdvertiserAgentCompliance =>
      'İlan verenler ve acenteler, DLD (Dubai Arazi Dairesi) gibi yetkililer tarafından belirlenen lisans ve reklam gereklilikleri dahil olmak üzere tüm ilgili BAE gayrimenkul düzenlemelerine uymalıdır.';

  @override
  String get myAccountTermsListingMust => 'Tüm mülk ilanları:';

  @override
  String get myAccountTermsListingRequirements =>
      '• Doğru, gerçek ve şu anda mevcut olmalıdır.\n• Güncel bilgi, resim, özellik ve fiyat içermelidir.\n• Geçerli yetki, mülkiyet belgeleri veya ilan anlaşmaları ile desteklenmelidir.';

  @override
  String get myAccountTermsAkaratRights => 'Akarat tam haklara sahiptir:';

  @override
  String get myAccountTermsAkaratRightsList =>
      '• İlanları yayınlamadan önce inceleme ve onaylama.\n• Kurallara aykırı içeriği düzenleme veya kaldırma.\n• Dürüst olmayan veya etik olmayan uygulamalarda bulunan hesapları askıya alma.';

  @override
  String get myAccountTermsAgentLicense =>
      'Acentelerin, emirete bağlı olarak geçerli bir DLD lisansı veya eşdeğer sertifikaya sahip olması gerekir.';

  @override
  String get myAccountTermsSectionUGCTitle => '7. Kullanıcı Üretilen İçerik';

  @override
  String get myAccountTermsUGCLicense =>
      'İçerik yükleyerek, Akarat\'a içeriği Platform ile ilgili amaçlar için saklama, yayınlama, çoğaltma, değiştirme veya kullanma konusunda küresel, münhasır olmayan, telifsiz bir lisans verirsiniz.';

  @override
  String get myAccountTermsUGCAffirm => 'Şunu beyan edersiniz:';

  @override
  String get myAccountTermsUGCAffirmList =>
      '• İçeriğin sahibi sizsiniz veya yasal kullanım hakkına sahipsiniz.\n• İçeriğiniz fikri mülkiyet kanunlarını ihlal etmemektedir.';

  @override
  String get myAccountTermsSectionIPTitle => '8. Fikri Mülkiyet';

  @override
  String get myAccountTermsIPOwnership =>
      'Platformdaki tüm fikri mülkiyet hakları; ticari markalar, hizmet markaları, logolar, grafikler, metinler, görüntüler, sesli-görsel materyaller, yazılımlar, tasarım unsurları ve diğer içerikler dahil ancak bunlarla sınırlı olmamak üzere, Akarat veya lisans verenlerinin münhasır mülkiyetidir.';

  @override
  String get myAccountTermsIPProhibited =>
      'Kullanıcıların kesinlikle yapmaması gerekenler:';

  @override
  String get myAccountTermsIPProhibitedList =>
      '• Önceden yazılı izin olmaksızın Platform içeriğini kopyalama, çoğaltma veya dağıtma.\n• Platformu veya içeriğini değiştirme, türev eserler oluşturma veya ticari olarak kullanma.\n• Akarat veya üçüncü taraf lisans verenlerinin haklarını ihlal edecek şekilde fikri mülkiyet kullanma.';

  @override
  String get myAccountTermsIPConsequence =>
      'Platformun fikri mülkiyetinin yetkisiz kullanımı, Birleşik Arap Emirlikleri yürürlükteki kanunları uyarınca medeni veya cezai sorumluluğa yol açabilir.';

  @override
  String get myAccountTermsSectionDisclaimerTitle =>
      '9. Sorumluluk Reddi ve Sorumluluk Sınırlandırması';

  @override
  String get myAccountTermsDisclaimerBasis =>
      'Platform ve Hizmetleri \"olduğu gibi\" ve \"mevcut olduğu şekilde\" sunulmaktadır. Akarat, Platform üzerinden sunulan herhangi bir içerik, ilan veya Hizmetin kullanılabilirliği, doğruluğu, eksiksizliği, güvenilirliği veya amaca uygunluğu konusunda açık veya zımni hiçbir garanti vermez.';

  @override
  String get myAccountTermsNoLiabilityFor =>
      'Kullanıcılar, Akarat\'ın aşağıdaki durumlardan sorumlu olmadığını kabul ve beyan eder:';

  @override
  String get myAccountTermsNoLiabilityList =>
      '• Mülk ilanlarında veya kullanıcı tarafından üretilen içerikteki hatalar, eksiklikler veya güncel olmayan bilgiler.\n• Dolaylı, arızi, sonuçsal, cezai veya özel zararlar; kâr kaybı, fırsat kaybı veya iş kesintisi dahil.\n• İlan verenler, acenteler, kullanıcılar veya üçüncü tarafların kötü niyetli davranışları, yanlış beyanları, ihmalleri veya eylemleri.';

  @override
  String get myAccountTermsUseAtOwnRisk =>
      'Kullanıcılar Platforma tamamen kendi riskleri altında erişir ve kullanır. Akarat\'ın toplam sorumluluğu, sözleşme, haksız fiil veya başka bir şekilde, ilgili Hizmetler için kullanıcı tarafından ödenen ücretleri (varsa) aşmayacaktır.';

  @override
  String get myAccountTermsSectionSuspensionTitle =>
      '10. Askıya Alma veya Fesih';

  @override
  String get myAccountTermsSuspensionRight =>
      'Akarat, kendi takdirine bağlı olarak, herhangi bir ön ihbar yapmaksızın bir kullanıcının hesabını ve Platform erişimini tamamen veya kısmen askıya alma, kısıtlama veya feshetme hakkını saklı tutar, eğer:';

  @override
  String get myAccountTermsSuspensionReasons =>
      '• Kullanıcı bu Şartların herhangi bir hükmünü veya yürürlükteki yasayı ihlal ederse.\n• Hileli, kötü niyetli veya etik olmayan faaliyet tespit edilirse.\n• Platformun veya diğer kullanıcıların güvenliği tehdit edilirse.';

  @override
  String get myAccountTermsSuspensionEffect =>
      'Askıya alma veya fesih üzerine, tüm Hizmetlere, içeriğe ve kullanıcı verilerine erişim derhal iptal edilir. Kullanıcılar, fesih öncesinde hesapları altında gerçekleştirilen tüm yükümlülüklerden ve eylemlerden sorumlu olmaya devam eder.';

  @override
  String get myAccountTermsSectionPrivacyTitle => '11. Veri Koruma ve Gizlilik';

  @override
  String get myAccountTermsPrivacyProcessed =>
      'Platform üzerinden toplanan tüm kişisel ve kişisel olmayan veriler, Akarat\'ın Gizlilik Politikasına uygun olarak işlenir. Temel uygulamalar şunlardır:';

  @override
  String get myAccountTermsPrivacyPractices =>
      '• Verilerin yalnızca operasyonel, yasal veya hizmetle ilgili amaçlar için toplanması.\n• Verilerin güvenli şekilde saklanması ve yalnızca yetkili personele erişim izni verilmesi.\n• Kişisel verilerin yalnızca Hizmetleri iyileştirme, işlem işleme veya yasal yükümlülüklere uyma amacıyla kullanılması.\n• Kullanıcıların kişisel bilgilerine erişme, düzeltme veya silme talep etme hakları, BAE yasalarına tabidir.';

  @override
  String get myAccountTermsPrivacyConsent =>
      'Platformu kullanarak, kullanıcılar Gizlilik Politikasında açıklandığı şekilde veri toplanmasına, işlenmesine ve saklanmasına rıza gösterir.';

  @override
  String get myAccountTermsSectionThirdPartyTitle =>
      '12. Üçüncü Taraf Bağlantıları';

  @override
  String get myAccountTermsThirdPartyContent =>
      'Platform üçüncü taraf web sitelerine, uygulamalara veya hizmetlere bağlantılar içerebilir. Akarat bu siteleri kontrol etmez, onaylamaz veya bunların doğruluğunu, içeriğini, gizliliğini veya güvenliğini garanti etmez.\n\nKullanıcılar, harici web sitelerine veya kaynaklara erişmenin kendi riskleri altında olduğunu kabul eder. Akarat, bu tür üçüncü taraf hizmetlerin kullanımından kaynaklanan herhangi bir zarar veya kayıptan sorumlu tutulamaz.';

  @override
  String get myAccountTermsSectionGoverningLawTitle =>
      '13. Uygulanacak Hukuk ve Yargı Yetkisi';

  @override
  String get myAccountTermsGoverningLawContent =>
      'Bu Şartlar, Birleşik Arap Emirlikleri yasalarına göre yönetilecek ve yorumlanacaktır. Bu Şartlardan veya Platform kullanımından kaynaklanan veya bunlarla ilgili herhangi bir uyuşmazlık, ihtilaf veya talep, Dubai\'deki yetkili mahkemelerin münhasır yargı yetkisine tabi olacaktır.\n\nKullanıcılar açıkça bu mahkemelerin yargı yetkisine tabi olur ve yargı yeri veya uygun olmayan forum itirazından feragat eder.';

  @override
  String get myAccountTermsSectionLanguageTitle => '14. Dil';

  @override
  String get myAccountTermsLanguageContent =>
      'Bu Şartlar kolaylık sağlamak amacıyla İngilizce ve Arapça olarak sunulmuştur. İngilizce ve Arapça sürümler arasında herhangi bir çelişki veya tutarsızlık olması durumunda, tüm yasal amaçlar, yorum ve uygulama için İngilizce sürüm geçerli olacaktır.';

  @override
  String get myAccountTermsSectionUpdatesTitle =>
      '15. Bu Şartlarda Güncellemeler';

  @override
  String get myAccountTermsUpdatesIntro =>
      'Akarat, aşağıdaki konulardaki değişiklikleri yansıtmak için bu Şartları herhangi bir zamanda değiştirme, gözden geçirme veya güncelleme hakkını saklı tutar:';

  @override
  String get myAccountTermsUpdatesReasons =>
      '• Yasal veya düzenleyici gereklilikler.\n• Operasyonel, teknik veya güvenlik iyileştirmeleri.\n• Platform üzerinden sunulan yeni özellikler, işlevler veya Hizmetler.';

  @override
  String get myAccountTermsUpdatesEffect =>
      'Güncellenmiş Şartlar, Platformda yayınlandığı anda yürürlüğe girer. Kullanıcıların Şartları periyodik olarak gözden geçirmesi önerilir. Platformu kullanmaya devam etmek, herhangi bir değişiklik veya güncellemeyi kabul ettiğiniz anlamına gelir.';

  @override
  String get myAccountTermsSectionContactTitle => '16. Bize Ulaşın';

  @override
  String get myAccountTermsContactContent =>
      'Yardım, soru veya şikayetler için:\n\n✉️ info@akarat.com\n\n📍 Westburry Ofis Kulesi, 23. Kat, Ofis 2303, Business Bay, Dubai, BAE';

  @override
  String get myAccountPrivacyAppBarTitle => 'Gizlilik Politikası';

  @override
  String get myAccountPrivacyIntroductionTitle => 'Giriş';

  @override
  String get myAccountPrivacyIntroductionContent =>
      'Gizliliğinizi korumak Akarat için önceliktir. Kişisel Verilerinizi korumaya ve web sitemiz ile mobil uygulamalarımızı (\"Platform\") kullandığınızda bu verilerin nasıl toplandığını, kullanıldığını ve açıklanacağını şeffaf bir şekilde paylaşmaya kararlıyız.\n\nBu Gizlilik Politikası, Platform\'a eriştiğinizde veya kullandığınızda Akarat\'ın Kişisel Verilerinizi nasıl topladığını, işlediğini ve yönettiğini açıklar ve haklarınızı ile size sunulan yasal korumaları belirtir.\n\nPlatform\'a erişerek veya kullanarak, Kişisel Verilerinizin bu Gizlilik Politikasına uygun olarak toplanmasını, kullanılmasını ve aktarılmasını kabul etmiş olursunuz.';

  @override
  String get myAccountPrivacySectionsIntro =>
      'Bu Gizlilik Politikası aşağıdaki bölümleri kapsar:';

  @override
  String get myAccountPrivacySectionLinkAbout =>
      'Şirketimiz ve iletişim bilgilerimiz hakkında';

  @override
  String get myAccountPrivacySectionLinkTypes => 'Topladığımız bilgi türleri';

  @override
  String get myAccountPrivacySectionLinkLegal =>
      'Bilgilerinizi işlemenin yasal dayanağı';

  @override
  String get myAccountPrivacySectionLinkShare =>
      'Bilgilerinizi kimlerle paylaşıyoruz?';

  @override
  String get myAccountPrivacySectionLinkSecurity => 'Veri Güvenliği Tedbirleri';

  @override
  String get myAccountPrivacySectionLinkRights =>
      'Bilgilerinizle ilgili haklarınız';

  @override
  String get myAccountPrivacySectionLinkMarketing =>
      'Pazarlama ve Promosyon İletişimi';

  @override
  String get myAccountPrivacySectionLinkMinors =>
      'Reşit Olmayanlar Hakkında Bilgi';

  @override
  String get myAccountPrivacySectionLinkThirdParty =>
      'Üçüncü Taraf Bağlantıları';

  @override
  String get myAccountPrivacySectionLinkUpdates =>
      'Politika Güncellemeleri ve Revizyonları';

  @override
  String get myAccountPrivacyFooterNote =>
      'Bu Gizlilik Politikasını periyodik olarak gözden geçirebiliriz. En güncel sürüm her zaman bu sayfada bulunacaktır.\n\nBu Politika farklı dillerde yayınlandığında ve herhangi bir tutarsızlık ortaya çıktığında, İngilizce sürüm geçerli olacaktır.';

  @override
  String get myAccountPrivacySectionWhoWeAreTitle =>
      'Biz Kimiz & Bize Nasıl Ulaşılır?';

  @override
  String get myAccountPrivacyWhoWeAreSubtitle => 'Biz kimiz?';

  @override
  String get myAccountPrivacyWhoWeAreContent =>
      'Platform, Birleşik Arap Emirlikleri\'nde kayıtlı olan EMLAK BULUCU tarafından işletilmektedir. Kayıtlı adresi: Westburry Ofis Kulesi, 23. Kat, Ofis No. 2303, Business Bay, Dubai, BAE (\"Akarat\", \"biz\", \"bize\", \"bizim\").';

  @override
  String get myAccountPrivacyContactSubtitle => 'Bize nasıl ulaşılır?';

  @override
  String get myAccountPrivacyContactContent =>
      'Bu Gizlilik Politikası ile ilgili herhangi bir sorunuz için info@akarat.com adresinden bizimle iletişime geçebilirsiniz.';

  @override
  String get myAccountPrivacySectionTypesTitle =>
      'Topladığımız Bilgiler & Nasıl Kullanıyoruz';

  @override
  String get myAccountPrivacyTypesIntro =>
      'Sizden doğrudan topladığımız Kişisel Veri kategorileri aşağıda açıklanmıştır.';

  @override
  String get myAccountPrivacyPersonalDataDefinition =>
      '\"Kişisel Veri\", sizi tanımlayan veya makul olarak sizi tanımlamak için kullanılabilecek herhangi bir bilgiyi ifade eder. Bu, sizi tanımlayamayan anonimleştirilmiş veya toplu verileri kapsamaz. Fotoğraflar, fiyatlar, açıklamalar ve özellikler gibi mülk ilan detayları Kişisel Veri sayılmaz, çünkü bunlar mülklerle ilgilidir ve bireyleri tanımlamaz.';

  @override
  String get myAccountPrivacyTypesCollectedIntro =>
      'Toplayabileceğimiz Kişisel Veri türleri şunlardır:';

  @override
  String get myAccountPrivacyTypesList =>
      '→ Kullanıcı Bilgileri\n→ Ajans Bilgileri\n→ Acente Bilgileri\n→ Mülk Oluşturma Bilgileri\n→ Sohbet Verileri\n→ Teknik Veriler\n→ Pazarlama Verileri';

  @override
  String get myAccountPrivacyUserInfoTitle =>
      '→ Kullanıcı Bilgileri (Kayıt ve Giriş için)';

  @override
  String get myAccountPrivacyUserInfoPurpose =>
      'Akarat.com\'a kaydolduğunuzda hesabınızı oluşturmak ve yönetmek, kimliğinizi doğrulamak ve Platform\'daki deneyiminizi kişiselleştirmek için belirli kişisel bilgileri toplarız.';

  @override
  String get myAccountPrivacyUserInfoCollectedTitle =>
      'Topladığımız Hesap ve Kimlik Detayları:';

  @override
  String get myAccountPrivacyUserInfoCollectedList =>
      '• Tam Ad (Ad ve Soyad)\n• E-posta Adresi\n• Cep Telefon Numarası (ülke kodu dahil)\n• WhatsApp Numarası\n• Şifre ve giriş bilgileri\n• Google ile Devam Et seçeneği kullanıldığında Google oturum açma detayları\n• Hesap kurulumu, giriş veya güvenlik kontrolleri için kullanılan doğrulama kodları veya OTP\'ler';

  @override
  String get myAccountPrivacyAgencyInfoTitle => '→ Ajans Bilgileri';

  @override
  String get myAccountPrivacyAgencyInfoList =>
      '• Ajans Adı ve Emirliği\n• Ulusal Kimlik ve mülk konumu\n• Ajansın kayıtlı lisans numarası\n• Ajansın kayıtlı logosu\n• Kayıtlı şirket lisans belgesi\n• Kayıtlı ofis kayıt numarası';

  @override
  String get myAccountPrivacyAgencyPurpose =>
      'İşletmenin meşruiyetini doğrulamak ve lisans gerekliliklerine uyumu sağlamak için ajans verilerini toplarız. Bu bilgiler, Akarat.com\'da doğrulanmış ajans profili oluşturup göstermemizi, kullanıcılar ile kayıtlı ajanslar arasında şeffaf iletişim sağlamamızı ve mülk ilanlarını ve ilgili acenteleri verimli bir şekilde yönetmemizi sağlar.';

  @override
  String get myAccountPrivacyAgencyPublicDisplayTitle =>
      'Akarat şunları kamuya açık olarak gösterebilir:';

  @override
  String get myAccountPrivacyAgencyPublicDisplayList =>
      '• Ajans adı, logosu, ORN ve iletişim bilgileri\n• Ofis adresi ve bağlı acenteler\n• Kamuya açık olarak listelenen mülkler (görüntülenmeler, ilanlar)\n\nHassas kayıt veya lisans belgeleri katı bir şekilde gizli tutulur.';

  @override
  String get myAccountPrivacyAgentInfoTitle => '→ Acente Bilgileri';

  @override
  String get myAccountPrivacyAgentInfoList =>
      '• Acente adı ve Emirliği\n• Kayıtlı Acente Lisans Numarası\n• Acente Ulusal Kimlik\n• Acente profil fotoğrafı\n• Cep telefonu numarası ve WhatsApp numarası\n• Milliyet';

  @override
  String get myAccountPrivacyAgentPurpose =>
      'RERA/DLD yönergelerine göre mesleki kimliklerini ve yetkilerini doğrulamak, Akarat.com\'da doğrulanmış acente profilleri göstermek ve acenteler ile potansiyel müşteriler arasında iletişimi kolaylaştırmak için acente verilerini toplarız. Yalnızca sınırlı bilgiler kamuya açık olarak gösterilir: acentenin adı, profil fotoğrafı, bağlı ajans adı ve logosu, aktif mülk ilanları.\n\nEmirates kimlik fotokopileri dahil hassas belgeler asla kamuya açıklanmaz.';

  @override
  String get myAccountPrivacyPropertyInfoTitle => '→ Mülk Oluşturma Bilgileri';

  @override
  String get myAccountPrivacyPropertyPurpose =>
      'Akarat.com\'da mülk listelediğinizde veya yönettiğinizde, ilanınızın eksiksiz, doğru ve uyumlu olmasını sağlamak için belirli detayları toplarız.';

  @override
  String get myAccountPrivacyPropertyCollectedTitle => 'Toplanan Bilgiler:';

  @override
  String get myAccountPrivacyPropertyCollectedList =>
      '• Emirlik ve Trakheesi lisans detayları\n• Mülk Başlığı ve Açıklama\n• Mülk türü (ör. daire, villa, ofis, arsa)\n• Konum ve harita koordinatları\n• Ödeme detayları ve kira süresi\n• Alan büyüklüğü, yatak odası ve banyo sayısı\n• Özellikler ve döşeme detayları\n• Mülkün müsaitlik durumu\n• Tüm proje ile ilgili detaylar\n• Yüklenen medya (Fotoğraflar, Kat Planları, YouTube Bağlantısı)';

  @override
  String get myAccountPrivacyTrakheesiNote =>
      'Trakheesi lisansı, Dubai Arazi Dairesi (DLD) tarafından RERA aracılığıyla verilen zorunlu bir izindir ve Dubai\'deki tüm gayrimenkul reklamlarını düzenler. İlanların meşru, izlenebilir ve uyumlu olmasını sağlar.\n\nMülk ilan bilgilerini potansiyel alıcılara veya kiracılara göstermek, doğruluğunu teyit etmek, arama doğruluğunu artırmak ve BAE\'de reklam uyumluluğunu sağlamak için toplarız.';

  @override
  String get myAccountPrivacyChatDataTitle => '→ Sohbet Verileri';

  @override
  String get myAccountPrivacyChatDataContent =>
      'Sohbet Verileri, Platform üzerinden değiştirdiğiniz mesajları ifade eder. Bu, gönderilen veya alınan tüm metinleri içerir. Bu verileri kullanıcılar ile acenteler arasındaki iletişimi kolaylaştırmak, sorulara yanıt vermek, destek sağlamak, etkileşim kayıtlarını tutmak ve hizmetlerimizi geliştirmek için kullanırız.\n\nSohbet Verileri gizlidir ve bu Gizlilik Politikasına uygun olarak güvenli bir şekilde saklanır.';

  @override
  String get myAccountPrivacyTechnicalDataTitle => '→ Teknik Veriler';

  @override
  String get myAccountPrivacyTechnicalDataList =>
      '• IP Adresi\n• Giriş Verileri\n• Tarayıcı türü ve sürümü\n• İşletim sistemi ve platform\n• Cihaz bilgileri\n• Saat dilimi ayarları';

  @override
  String get myAccountPrivacyTechnicalPurpose =>
      'Kullanıcıların Platform ile nasıl etkileşime girdiğini anlamak, sorunları teşhis etmek, performansı ve işlevselliği iyileştirmek, güvenliği artırmak ve kullanıcı deneyimini optimize etmek için teknik verileri toplarız. Bu veriler ayrıca analiz, dolandırıcılık tespiti ve düzenleyici uyumluluk için kullanılabilir.';

  @override
  String get myAccountPrivacyMarketingDataTitle => '→ Pazarlama Verileri';

  @override
  String get myAccountPrivacyMarketingContent =>
      'Yeni mülk uyarıları, hesap durumu güncellemeleri, sorgu bildirimleri veya promosyonel mesajlar almak isteyip istemediğiniz dahil pazarlama tercihleriniz hakkında bilgi toplayabilir ve saklayabiliriz. Bu, iletişimleri ilgi alanlarınıza göre uyarlamamıza yardımcı olur.\n\nHerhangi bir pazarlama e-postasındaki \"Abonelikten Çık\" bağlantısına tıklayarak veya info@akarat.com adresinden bizimle iletişime geçerek istediğiniz zaman vazgeçebilirsiniz. Vazgeçmek Platform\'u kullanma yeteneğinizi etkilemez.';

  @override
  String get myAccountPrivacyRefusalTitle =>
      'Gerekli Kişisel Verileri sağlamayı reddederseniz ne olur?';

  @override
  String get myAccountPrivacyRefusalContent =>
      'Bize Kişisel Veri sağlamak zorunda değilsiniz. Ancak Platform\'a erişim veya yasal gereklilikler için belirli veriler gerekliyse ve bunları sağlamazsanız erişim sağlayamayabiliriz. Örneğin, Akarat.com\'da hesap oluşturmak için e-posta adresiniz gereklidir.';

  @override
  String get myAccountPrivacySectionLegalTitle => 'İşlemenin Yasal Dayanağı';

  @override
  String get myAccountPrivacyLegalIntro =>
      'Geçerli gizlilik yasalarına göre, Kişisel Verilerinizi kullandığımız her amaç için geçerli bir yasal dayanak olması gerekir. Çoğu durumda aşağıdaki dayanaklardan birine güveniriz:';

  @override
  String get myAccountPrivacyLegalBases =>
      '• Sözleşmesel Gereklilik – Kişisel Verilerinizi sizinle yaptığımız sözleşmeyi yerine getirmek için işlemenin gerektiği durumlarda (örneğin Platform\'a erişiminizi sağlamak).\n\n• Yasal Uyum – Yasal veya düzenleyici gereklilikleri karşılamak için Kişisel Verilerinizi işlemenin zorunlu olduğu durumlarda.\n\n• Onay – Kişisel Verilerinizi belirli bir amaç için işlememize açıkça izin verdiğiniz durumlarda.';

  @override
  String get myAccountPrivacySectionShareTitle =>
      'Bilgilerinizi Kimlerle Paylaşıyoruz?';

  @override
  String get myAccountPrivacyShareContent =>
      'Kişisel Verilerinizi alan tüm tarafların, politikalarımız ve geçerli veri koruma yükümlülükleriyle uyumlu uygun güvenlik önlemleri uygulamasını talep ederiz. Adımıza Kişisel Veri işleyen üçüncü taraf hizmet sağlayıcıların bu verileri kendi amaçları için kullanmasına izin vermeyiz. Yalnızca bizim tanımladığımız belirli amaçlar için ve yalnızca talimatlarımıza tam olarak uygun şekilde işlemelerine izin verilir.\n\nPlatform\'un diğer kullanıcılarıyla işlem yapmaya karar verdiğinizde belirli Kişisel Verileri onlarla paylaşmamız gerekebilir. Örneğin, bir Acente tarafından listelenen bir mülke ilgi gösterdiğinizde, o Acente\'nin ilgili temsilcileri Kişisel Verilerinize erişim talep edebilir.';

  @override
  String get myAccountPrivacySectionSecurityTitle =>
      'Verilerinizi Nasıl Güvende Tutuyoruz';

  @override
  String get myAccountPrivacySecurityContent =>
      'Kişisel Verilerinizi kazara kayıp, değişiklik, yetkisiz erişim veya kötüye kullanımdan korumak için uygun güvenlik önlemleri uygulamaktayız.\n\nKişisel Verilerinize erişim, meşru iş amaçları için buna ihtiyaç duyan çalışanlar ve yetkili personelle sınırlıdır. Bu erişime sahip tüm kişiler gizlilik yükümlülüklerine tabidir.\n\nAyrıca herhangi bir gerçek veya şüpheli Kişisel Veri ihlalini tespit etmek, yönetmek ve yanıtlamak için güçlü prosedürler sürdürürüz. Böyle durumlarda gizliliğiniz üzerindeki olası etkiyi en aza indirmek için derhal adım atarız ve gerektiğinde ilgili düzenleyici makamlarla iş birliği yaparız.';

  @override
  String get myAccountPrivacySectionRightsTitle => 'Haklarınız';

  @override
  String get myAccountPrivacyRightsIntro =>
      'Geçerli veri koruma yasalarına ve Kişisel Verilerinizin kontrolümüz altında olduğu yere bağlı olarak aşağıdaki haklara sahip olabilirsiniz:';

  @override
  String get myAccountPrivacyRightsList =>
      '• Erişim — Hakkınızda tuttuğumuz Kişisel Verilerin bir kopyasını talep etme.\n• Düzeltme — Yanlış veya eksik bilgileri güncelleme veya düzeltme talebinde bulunma.\n• Silme — Artık orijinal amacı için gerekli olmadığında Kişisel Verilerin silinmesini talep etme.\n• İşlemeyi Kısıtlama — Verilerinizin tamamının veya bir kısmının geçici veya kalıcı olarak işlenmesini durdurmamızı isteme.\n• İtiraz — Meşru menfaatlerimize dayalı işlemeye veya doğrudan pazarlamaya itiraz etme.\n• Veri Taşınabilirliği — Kişisel Verilerinizin yapılandırılmış, makine tarafından okunabilir bir kopyasını talep etme.\n• Onayın Geri Çekilmesi — İşleme izninize dayanıyorsa onayı geri çekme.\n\nBu haklardan herhangi birini kullanmak isterseniz lütfen bizimle iletişime geçin.';

  @override
  String get myAccountPrivacySectionMarketingTitle => 'Pazarlama İletişimi';

  @override
  String get myAccountPrivacySectionMinorsTitle =>
      'Reşit Olmayanlar İçin Gizliliğimiz';

  @override
  String get myAccountPrivacyMinorsContent =>
      'Bu Platform 18 yaşından küçük kişiler için tasarlanmamıştır. Reşit olmayanlardan bilerek veri toplamayız veya kullanıcı yaşını doğrulamayız. Bir reşit olmayanın Platform\'u kullandığını düşünüyorsanız, lütfen info@akarat.com adresinden bizi bilgilendirin; böylece ilgili Kişisel Verileri kaldırabilir ve daha fazla erişimi engelleyebiliriz.';

  @override
  String get myAccountPrivacySectionThirdPartyTitle =>
      'Üçüncü Taraf Bağlantıları';

  @override
  String get myAccountPrivacyThirdPartyContent =>
      'Platform üçüncü taraf web sitelerine veya hizmetlere bağlantılar içerebilir. Akarat, harici sitelerin içeriği, kullanılabilirliği veya gizlilik uygulamalarından sorumlu değildir. Platform\'dan ayrıldığınızda, ziyaret ettiğiniz her sitenin gizlilik politikalarını incelemenizi öneririz.';

  @override
  String get myAccountPrivacySectionUpdatesTitle =>
      'Gizlilik Politikasında Değişiklikler';

  @override
  String get myAccountPrivacyUpdatesContent =>
      'Bu Gizlilik Politikasını herhangi bir zamanda, önceden haber vermeksizin güncelleyebiliriz. Güncellemeler olduğunda bu sayfayı revize edeceğiz ve bazı durumlarda sizi doğrudan bilgilendirebiliriz (örneğin e-posta ile). Tüm değişiklikler yayınlandığı anda yürürlüğe girer.';

  @override
  String get aboutUs_hero_title => 'Akarat Hakkında';

  @override
  String get aboutUs_hero_subtitle =>
      'Güven İçin İnşa Edildi. Gelecek İçin Tasarlandı.';

  @override
  String get aboutUs_intro_paragraph_1 =>
      'Akarat sadece bir emlak platformu değil — BAE\'deki insanları mülklerle bağlamanın daha akıllı bir yoludur.';

  @override
  String get aboutUs_intro_paragraph_2 =>
      'Doğrulanmış ilanları, güçlü teknolojiyi ve kullanıcı odaklı yaklaşımı bir araya getirerek herkesin güvenle başarılı olmasına yardımcı oluyoruz.';

  @override
  String get aboutUs_get_started_button => 'Başlayın';

  @override
  String get aboutUs_features_heading_part1 => 'Biz Ne';

  @override
  String get aboutUs_features_heading_part2 => 'Sunuyoruz';

  @override
  String get aboutUs_features_subtitle =>
      'Emlak başarısı için özel olarak hazırlanmış akıllı araçlar ve doğrulanmış ilanlar.';

  @override
  String get aboutUs_feature_verified_listings_title => 'Doğrulanmış İlanlar';

  @override
  String get aboutUs_feature_verified_listings_desc =>
      'Güven ve şeffaflık oluşturmak için %100 doğrulanmış mülkler.';

  @override
  String get aboutUs_feature_smart_filters_title => 'Akıllı Filtreler';

  @override
  String get aboutUs_feature_smart_filters_desc =>
      'Aramanızı daraltmak için gelişmiş konum ve yaşam tarzı filtreleri.';

  @override
  String get aboutUs_feature_agent_dashboard_title => 'Danışman Paneli';

  @override
  String get aboutUs_feature_agent_dashboard_desc =>
      'İlan görüntülemelerini, potansiyel müşterileri ve pazarlama performansını takip edin.';

  @override
  String get aboutUs_feature_offplan_projects_title =>
      'Proje Halindeki Yatırımlar';

  @override
  String get aboutUs_feature_offplan_projects_desc =>
      'Özel görünürlük ile gelecekteki gelişmeleri sergileyin.';

  @override
  String get aboutUs_feature_web_app_access_title => 'Web ve Uygulama Erişimi';

  @override
  String get aboutUs_feature_web_app_access_desc =>
      'Çevrimiçi ve mobil cihazlarda kesintisiz tarama deneyimi.';

  @override
  String get aboutUs_feature_growth_tools_title => 'Büyüme Araçları';

  @override
  String get aboutUs_feature_growth_tools_desc =>
      'Markanızı ve erişiminizi artırmak için pazarlama ve veri içgörüleri.';

  @override
  String get aboutUs_audience_heading => 'Hedef Kitlemiz';

  @override
  String get aboutUs_audience_subtitle =>
      'Tüm emlak ekosistemine gururla hizmet ediyoruz';

  @override
  String get aboutUs_audience_pill_investors => '💼 Emlak Yatırımcıları';

  @override
  String get aboutUs_audience_pill_agents =>
      '👨‍💼 Emlak Danışmanları & Ajanslar';

  @override
  String get aboutUs_audience_pill_relocation => '🚚 Taşınma Hizmetleri';

  @override
  String get aboutUs_audience_pill_developers =>
      '🏗️ Geliştiriciler & Aracılar';

  @override
  String get aboutUs_audience_pill_buyers => '🏠 Ev Alıcıları & Kiracılar';

  @override
  String get aboutUs_story_heading => 'Hikayemiz';

  @override
  String get aboutUs_story_main_title => 'Akarat\'ı tek bir amaçla başlattık';

  @override
  String get aboutUs_story_paragraph_1 =>
      'Gerçek ilanlar, gerçek araçlar ve gerçek sonuçlar sunarak emlak arayışı ve pazarlamadaki hayal kırıklığını ortadan kaldırmak.';

  @override
  String get aboutUs_story_paragraph_2 =>
      'Netlik ve güven getirme misyonu olarak başlayan şey, BAE genelinde güvenilen tam özellikli bir platforma dönüştü.';

  @override
  String get aboutUs_story_stat_clients_number => '600 +';

  @override
  String get aboutUs_story_stat_clients_label => 'Uluslararası Müşteri';

  @override
  String get aboutUs_story_stat_offices_number => '40 +';

  @override
  String get aboutUs_story_stat_offices_label => 'Dünya Çapında Ofis';

  @override
  String get aboutUs_explore_heading_part1 =>
      'Akarat\'ın En İyi Özelliklerini Keşfedin';

  @override
  String get aboutUs_services_heading => 'Hizmetlerimiz';

  @override
  String get aboutUs_services_subheading => 'Kime Hizmet Veriyoruz';

  @override
  String get aboutUs_services_intro =>
      'Doğruluğu ve güveni sağlamak için gerçek zamanlı güncellenen doğrulanmış ilanlarımız aracılığıyla ideal evinizi bulun.';

  @override
  String get aboutUs_explore_verified_listings_title => 'Doğrulanmış İlanlar';

  @override
  String get aboutUs_explore_verified_listings_desc =>
      'Her ilan, gerçeklik, fiyat doğruluğu ve müsaitlik açısından manuel olarak incelenir ve doğrulanır.';

  @override
  String get aboutUs_explore_smart_location_title => 'Akıllı Konum Arama';

  @override
  String get aboutUs_explore_smart_location_desc =>
      'Akıllı filtrelerimizle bölge, topluluk, simge yapı veya yaşam tarzı tercihine göre mülk keşfedin.';

  @override
  String get aboutUs_explore_agent_dashboard_title => 'Danışman Paneli';

  @override
  String get aboutUs_explore_agent_dashboard_desc =>
      'Ajanslar ve danışmanlar potansiyel müşterileri, görüntülemeleri ve mülk performansını takip etmek için özel bir arka uç elde eder.';

  @override
  String get aboutUs_service_card_buyers_title => 'Ev Alıcıları & Kiracılar';

  @override
  String get aboutUs_service_card_buyers_desc =>
      'Gerçek zamanlı güncellemelerle doğrulanmış ilanları keşfedin';

  @override
  String get aboutUs_service_card_agents_title =>
      'Emlak Danışmanları & Ajanslar';

  @override
  String get aboutUs_service_card_agents_desc =>
      'Potansiyel müşteri kazanın, ilanları tanıtın ve markanızı oluşturun';

  @override
  String get aboutUs_service_card_developers_title => 'Geliştiriciler';

  @override
  String get aboutUs_service_card_developers_desc =>
      'Zengin medya ve öne çıkan promosyonlarla proje halindeki mülkleri sergileyin';

  @override
  String get aboutUs_service_card_investors_title => 'Yatırımcılar';

  @override
  String get aboutUs_service_card_investors_desc =>
      'Yeni projeleri ve kârlı fırsatları keşfedin';

  @override
  String get aboutUs_service_card_providers_title => 'Hizmet Sağlayıcılar';

  @override
  String get aboutUs_service_card_providers_desc =>
      'Taşınma, dekorasyon, mortgage ve hukuki hizmetleri tanıtın';

  @override
  String get aboutUs_footer_email => 'info@akarat.com';

  @override
  String get aboutUs_start_project_button => 'Bir Projeye Başla';

  @override
  String get aboutUs_login_dialog_title => 'Giriş Gereklidir';

  @override
  String get aboutUs_login_dialog_message =>
      'Favorilere erişmek için lütfen giriş yapın.';

  @override
  String get aboutUs_login_dialog_cancel => 'İptal';

  @override
  String get aboutUs_login_dialog_login => 'Giriş Yap';

  @override
  String get aboutUs_services_whoWeServe_title => 'Kime Hizmet Veriyoruz';

  @override
  String get aboutUs_explore_verified_title => 'Doğrulanmış İlanlar';

  @override
  String get aboutUs_explore_verified_desc =>
      'Her ilan, gerçeklik, fiyat doğruluğu ve müsaitlik açısından manuel olarak incelenir ve doğrulanır.';

  @override
  String get aboutUs_service_buyers_renters_title => 'Ev Alıcıları & Kiracılar';

  @override
  String get aboutUs_service_buyers_renters_desc =>
      'Gerçek zamanlı güncellemelerle doğrulanmış ilanları keşfedin';

  @override
  String get aboutUs_service_agents_agencies_title =>
      'Emlak Danışmanları & Ajanslar';

  @override
  String get aboutUs_service_agents_agencies_desc =>
      'Potansiyel müşteri kazanın, ilanları tanıtın ve markanızı oluşturun';

  @override
  String get aboutUs_service_developers_title => 'Geliştiriciler';

  @override
  String get aboutUs_service_developers_desc =>
      'Zengin medya ve öne çıkan promosyonlarla proje halindeki mülkleri sergileyin';

  @override
  String get aboutUs_service_investors_title => 'Yatırımcılar';

  @override
  String get aboutUs_service_investors_desc =>
      'Yeni projeleri ve kârlı fırsatları keşfedin';

  @override
  String get aboutUs_service_providers_title => 'Hizmet Sağlayıcılar';

  @override
  String get aboutUs_service_providers_desc =>
      'Taşınma, dekorasyon, mortgage ve hukuki hizmetleri tanıtın';

  @override
  String get aboutUs_hero_brand_name => 'Akarat';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'ماتريكس فلسطين'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get commonSearch;

  /// No description provided for @commonSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get commonSeeAll;

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارِ التحميل...'**
  String get commonLoading;

  /// No description provided for @commonNoInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get commonNoInternet;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما. الرجاء المحاولة مرة أخرى'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get commonEmptyTitle;

  /// No description provided for @commonCurrency.
  ///
  /// In ar, this message translates to:
  /// **'₪'**
  String get commonCurrency;

  /// No description provided for @commonOnline.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get commonOnline;

  /// No description provided for @commonOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get commonOffline;

  /// No description provided for @commonLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get commonLogout;

  /// No description provided for @commonYes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get commonNo;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @commonShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get commonShare;

  /// No description provided for @commonPrint.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get commonPrint;

  /// No description provided for @commonView.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get commonView;

  /// No description provided for @commonCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get commonCall;

  /// No description provided for @commonFrom.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get commonFrom;

  /// No description provided for @commonTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get commonTo;

  /// No description provided for @commonFilter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get commonFilter;

  /// No description provided for @commonNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get commonNotes;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navCustomers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get navCustomers;

  /// No description provided for @navSales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get navSales;

  /// No description provided for @navCollections.
  ///
  /// In ar, this message translates to:
  /// **'التحصيل'**
  String get navCollections;

  /// No description provided for @navMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @navStock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get navStock;

  /// No description provided for @navDocuments.
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get navDocuments;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بياناتك للمتابعة'**
  String get loginSubtitle;

  /// No description provided for @loginUsername.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم / البريد الإلكتروني'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get loginPassword;

  /// No description provided for @loginRememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get loginRememberMe;

  /// No description provided for @loginSubmit.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginSubmit;

  /// No description provided for @loginBiometric.
  ///
  /// In ar, this message translates to:
  /// **'الدخول ببصمة الإصبع'**
  String get loginBiometric;

  /// No description provided for @loginBiometricFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التحقق من البصمة. حاول مرة أخرى.'**
  String get loginBiometricFailed;

  /// No description provided for @loginValidationRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get loginValidationRequired;

  /// No description provided for @loginFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول'**
  String get loginFailedTitle;

  /// No description provided for @moreProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get moreProfile;

  /// No description provided for @moreLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get moreLanguage;

  /// No description provided for @moreLanguageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get moreLanguageArabic;

  /// No description provided for @moreLanguageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get moreLanguageEnglish;

  /// No description provided for @moreLogoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get moreLogoutConfirm;

  /// No description provided for @dashboardGoodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get dashboardGoodMorning;

  /// No description provided for @dashboardGoodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get dashboardGoodAfternoon;

  /// No description provided for @dashboardGoodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get dashboardGoodEvening;

  /// No description provided for @dashboardTodaySales.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم'**
  String get dashboardTodaySales;

  /// No description provided for @dashboardCollections.
  ///
  /// In ar, this message translates to:
  /// **'التحصيلات'**
  String get dashboardCollections;

  /// No description provided for @dashboardReceivables.
  ///
  /// In ar, this message translates to:
  /// **'الذمم المدينة'**
  String get dashboardReceivables;

  /// No description provided for @dashboardTodayInvoices.
  ///
  /// In ar, this message translates to:
  /// **'فواتير اليوم'**
  String get dashboardTodayInvoices;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardNewSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get dashboardNewSale;

  /// No description provided for @dashboardCollectPayment.
  ///
  /// In ar, this message translates to:
  /// **'تحصيل دفعة'**
  String get dashboardCollectPayment;

  /// No description provided for @dashboardReturn.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get dashboardReturn;

  /// No description provided for @dashboardMyStock.
  ///
  /// In ar, this message translates to:
  /// **'مخزوني'**
  String get dashboardMyStock;

  /// No description provided for @dashboardCustomers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get dashboardCustomers;

  /// No description provided for @dashboardProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get dashboardProducts;

  /// No description provided for @dashboardTotalProducts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المنتجات'**
  String get dashboardTotalProducts;

  /// No description provided for @dashboardLowStock.
  ///
  /// In ar, this message translates to:
  /// **'مخزون منخفض'**
  String get dashboardLowStock;

  /// No description provided for @dashboardTodayReceipts.
  ///
  /// In ar, this message translates to:
  /// **'إضافات اليوم'**
  String get dashboardTodayReceipts;

  /// No description provided for @dashboardTodayIssues.
  ///
  /// In ar, this message translates to:
  /// **'صرفيات اليوم'**
  String get dashboardTodayIssues;

  /// No description provided for @syncPending.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, one{معاملة واحدة بانتظار المزامنة} two{معاملتان بانتظار المزامنة} other{{count} معاملات بانتظار المزامنة}}'**
  String syncPending(int count);

  /// No description provided for @syncedUpToDate.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة'**
  String get syncedUpToDate;

  /// No description provided for @productFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم العثور على المنتج'**
  String get productFoundTitle;

  /// No description provided for @productNotFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'المنتج غير موجود'**
  String get productNotFoundTitle;

  /// No description provided for @productAvailable.
  ///
  /// In ar, this message translates to:
  /// **'المتوفر'**
  String get productAvailable;

  /// No description provided for @productSellingPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر البيع'**
  String get productSellingPrice;

  /// No description provided for @productAddToInvoice.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إلى الفاتورة'**
  String get productAddToInvoice;

  /// No description provided for @productSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن منتج'**
  String get productSearchHint;

  /// No description provided for @productScanBarcode.
  ///
  /// In ar, this message translates to:
  /// **'مسح الباركود'**
  String get productScanBarcode;

  /// No description provided for @productScanInstruction.
  ///
  /// In ar, this message translates to:
  /// **'وجّه الكاميرا نحو الباركود'**
  String get productScanInstruction;

  /// No description provided for @productsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get productsEmpty;

  /// No description provided for @productNewProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج جديد'**
  String get productNewProduct;

  /// No description provided for @productBarcode.
  ///
  /// In ar, this message translates to:
  /// **'الباركود'**
  String get productBarcode;

  /// No description provided for @productCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get productCategory;

  /// No description provided for @productAddCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فئة جديدة'**
  String get productAddCategory;

  /// No description provided for @productBrand.
  ///
  /// In ar, this message translates to:
  /// **'الماركة'**
  String get productBrand;

  /// No description provided for @productAddBrand.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ماركة جديدة'**
  String get productAddBrand;

  /// No description provided for @productBaseUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة الأساسية'**
  String get productBaseUnit;

  /// No description provided for @productAddUnit.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وحدة جديدة'**
  String get productAddUnit;

  /// No description provided for @productUnitSymbol.
  ///
  /// In ar, this message translates to:
  /// **'الرمز (مثال: PC)'**
  String get productUnitSymbol;

  /// No description provided for @productReorderLevel.
  ///
  /// In ar, this message translates to:
  /// **'حد إعادة الطلب'**
  String get productReorderLevel;

  /// No description provided for @productAddBulkUnit.
  ///
  /// In ar, this message translates to:
  /// **'إضافة وحدة بيع أكبر (مثل كرتون)'**
  String get productAddBulkUnit;

  /// No description provided for @productBulkUnit.
  ///
  /// In ar, this message translates to:
  /// **'الوحدة الأكبر'**
  String get productBulkUnit;

  /// No description provided for @productBulkConversion.
  ///
  /// In ar, this message translates to:
  /// **'عدد الوحدة الأساسية داخلها'**
  String get productBulkConversion;

  /// No description provided for @productAddOpeningStock.
  ///
  /// In ar, this message translates to:
  /// **'إضافة رصيد افتتاحي'**
  String get productAddOpeningStock;

  /// No description provided for @productOpeningQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية الافتتاحية'**
  String get productOpeningQuantity;

  /// No description provided for @productSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المنتج'**
  String get productSave;

  /// No description provided for @productValidationRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالإنجليزي والعربي، الوحدة الأساسية، وسعر البيع كلها مطلوبة'**
  String get productValidationRequired;

  /// No description provided for @customerBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get customerBalance;

  /// No description provided for @customerCreditLimit.
  ///
  /// In ar, this message translates to:
  /// **'سقف الائتمان'**
  String get customerCreditLimit;

  /// No description provided for @customerNewSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get customerNewSale;

  /// No description provided for @customerPayment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get customerPayment;

  /// No description provided for @customerStatement.
  ///
  /// In ar, this message translates to:
  /// **'كشف حساب'**
  String get customerStatement;

  /// No description provided for @customerCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get customerCall;

  /// No description provided for @customerSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم، الهاتف، الرمز، المنطقة'**
  String get customerSearchHint;

  /// No description provided for @customersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء'**
  String get customersEmpty;

  /// No description provided for @customerTabOverview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get customerTabOverview;

  /// No description provided for @customerTabSales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get customerTabSales;

  /// No description provided for @customerTabPayments.
  ///
  /// In ar, this message translates to:
  /// **'الدفعات'**
  String get customerTabPayments;

  /// No description provided for @customerTabStatement.
  ///
  /// In ar, this message translates to:
  /// **'كشف الحساب'**
  String get customerTabStatement;

  /// No description provided for @customerAvailableCredit.
  ///
  /// In ar, this message translates to:
  /// **'الائتمان المتاح'**
  String get customerAvailableCredit;

  /// No description provided for @customerOpeningBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الافتتاحي'**
  String get customerOpeningBalance;

  /// No description provided for @customerClosingBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get customerClosingBalance;

  /// No description provided for @customerNoPhone.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم هاتف'**
  String get customerNoPhone;

  /// No description provided for @customerNewCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عميل جديد'**
  String get customerNewCustomer;

  /// No description provided for @customerFieldName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (إنجليزي)'**
  String get customerFieldName;

  /// No description provided for @customerFieldNameAr.
  ///
  /// In ar, this message translates to:
  /// **'الاسم (عربي)'**
  String get customerFieldNameAr;

  /// No description provided for @customerFieldPhone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get customerFieldPhone;

  /// No description provided for @customerFieldSecondaryPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف إضافي'**
  String get customerFieldSecondaryPhone;

  /// No description provided for @customerFieldArea.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة'**
  String get customerFieldArea;

  /// No description provided for @customerFieldCity.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get customerFieldCity;

  /// No description provided for @customerFieldAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get customerFieldAddress;

  /// No description provided for @customerFieldCreditLimit.
  ///
  /// In ar, this message translates to:
  /// **'سقف الائتمان'**
  String get customerFieldCreditLimit;

  /// No description provided for @customerFieldPaymentTerms.
  ///
  /// In ar, this message translates to:
  /// **'مدة السداد (أيام)'**
  String get customerFieldPaymentTerms;

  /// No description provided for @customerSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ العميل'**
  String get customerSave;

  /// No description provided for @customerCreatedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة العميل'**
  String get customerCreatedTitle;

  /// No description provided for @customerNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالإنجليزي والعربي مطلوبان'**
  String get customerNameRequired;

  /// No description provided for @saleSelectCustomer.
  ///
  /// In ar, this message translates to:
  /// **'اختر العميل'**
  String get saleSelectCustomer;

  /// No description provided for @saleSearchCustomer.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن عميل...'**
  String get saleSearchCustomer;

  /// No description provided for @saleAddProducts.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتجات'**
  String get saleAddProducts;

  /// No description provided for @saleCart.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get saleCart;

  /// No description provided for @saleCartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'السلة فارغة'**
  String get saleCartEmpty;

  /// No description provided for @saleQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get saleQuantity;

  /// No description provided for @salePrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get salePrice;

  /// No description provided for @saleTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get saleTotal;

  /// No description provided for @saleSubtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get saleSubtotal;

  /// No description provided for @saleDiscount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get saleDiscount;

  /// No description provided for @salePaid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get salePaid;

  /// No description provided for @saleRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get saleRemaining;

  /// No description provided for @salePaymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get salePaymentMethod;

  /// No description provided for @salePaymentCash.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get salePaymentCash;

  /// No description provided for @salePaymentBankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي'**
  String get salePaymentBankTransfer;

  /// No description provided for @salePaymentCheque.
  ///
  /// In ar, this message translates to:
  /// **'شيك'**
  String get salePaymentCheque;

  /// No description provided for @salePaymentCredit.
  ///
  /// In ar, this message translates to:
  /// **'آجل'**
  String get salePaymentCredit;

  /// No description provided for @salePaymentPartial.
  ///
  /// In ar, this message translates to:
  /// **'دفعة جزئية'**
  String get salePaymentPartial;

  /// No description provided for @saleConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد البيع'**
  String get saleConfirm;

  /// No description provided for @saleReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الفاتورة'**
  String get saleReview;

  /// No description provided for @saleCompletedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إنجاز عملية البيع'**
  String get saleCompletedTitle;

  /// No description provided for @saleInvoiceNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الفاتورة'**
  String get saleInvoiceNumber;

  /// No description provided for @saleViewInvoice.
  ///
  /// In ar, this message translates to:
  /// **'عرض الفاتورة'**
  String get saleViewInvoice;

  /// No description provided for @saleNewSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get saleNewSale;

  /// No description provided for @saleSharePdf.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة PDF'**
  String get saleSharePdf;

  /// No description provided for @salesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير'**
  String get salesEmpty;

  /// No description provided for @saleStatusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'مؤكدة'**
  String get saleStatusConfirmed;

  /// No description provided for @saleStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get saleStatusCancelled;

  /// No description provided for @saleNextStep.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get saleNextStep;

  /// No description provided for @saleBackStep.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get saleBackStep;

  /// No description provided for @saleMustSelectCustomer.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار عميل'**
  String get saleMustSelectCustomer;

  /// No description provided for @saleMustAddProduct.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إضافة منتج واحد على الأقل'**
  String get saleMustAddProduct;

  /// No description provided for @paymentCurrentBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي'**
  String get paymentCurrentBalance;

  /// No description provided for @paymentAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الدفعة'**
  String get paymentAmount;

  /// No description provided for @paymentReference.
  ///
  /// In ar, this message translates to:
  /// **'المرجع'**
  String get paymentReference;

  /// No description provided for @paymentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الدفعة'**
  String get paymentConfirm;

  /// No description provided for @paymentRecordedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدفعة'**
  String get paymentRecordedTitle;

  /// No description provided for @paymentPreviousBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد السابق'**
  String get paymentPreviousBalance;

  /// No description provided for @paymentNewBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الجديد'**
  String get paymentNewBalance;

  /// No description provided for @paymentsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دفعات'**
  String get paymentsEmpty;

  /// No description provided for @paymentSelectCustomerFirst.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار عميل أولاً'**
  String get paymentSelectCustomerFirst;

  /// No description provided for @stockAvailable.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المتوفرة'**
  String get stockAvailable;

  /// No description provided for @stockLowBadge.
  ///
  /// In ar, this message translates to:
  /// **'منخفض'**
  String get stockLowBadge;

  /// No description provided for @stockEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات مخزون'**
  String get stockEmpty;

  /// No description provided for @moreVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get moreVersion;

  /// No description provided for @returnSelectInvoice.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفاتورة'**
  String get returnSelectInvoice;

  /// No description provided for @returnSelectProducts.
  ///
  /// In ar, this message translates to:
  /// **'اختر المنتجات المرتجعة'**
  String get returnSelectProducts;

  /// No description provided for @returnQuantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المرتجعة'**
  String get returnQuantity;

  /// No description provided for @returnMaxReturnable.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للإرجاع'**
  String get returnMaxReturnable;

  /// No description provided for @returnConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد المرتجع'**
  String get returnConfirm;

  /// No description provided for @returnCompletedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل المرتجع'**
  String get returnCompletedTitle;

  /// No description provided for @returnsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مرتجعات'**
  String get returnsEmpty;

  /// No description provided for @returnNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم المرتجع'**
  String get returnNumber;

  /// No description provided for @returnNewReturn.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع جديد'**
  String get returnNewReturn;

  /// No description provided for @vehicleLoadNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحميل مركبة جديد'**
  String get vehicleLoadNewTitle;

  /// No description provided for @vehicleLoadSelectVehicle.
  ///
  /// In ar, this message translates to:
  /// **'اختر المركبة'**
  String get vehicleLoadSelectVehicle;

  /// No description provided for @vehicleLoadSelectRep.
  ///
  /// In ar, this message translates to:
  /// **'اختر المندوب'**
  String get vehicleLoadSelectRep;

  /// No description provided for @vehicleLoadSelectWarehouse.
  ///
  /// In ar, this message translates to:
  /// **'اختر المستودع'**
  String get vehicleLoadSelectWarehouse;

  /// No description provided for @vehicleLoadAddProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get vehicleLoadAddProduct;

  /// No description provided for @vehicleLoadConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التحميل'**
  String get vehicleLoadConfirm;

  /// No description provided for @vehicleLoadCompletedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تحميل المركبة'**
  String get vehicleLoadCompletedTitle;

  /// No description provided for @vehicleLoadsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تحميلات'**
  String get vehicleLoadsEmpty;

  /// No description provided for @vehicleLoadNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم التحميل'**
  String get vehicleLoadNumber;

  /// No description provided for @vehicleLoadStatusLoaded.
  ///
  /// In ar, this message translates to:
  /// **'محمّلة'**
  String get vehicleLoadStatusLoaded;

  /// No description provided for @vehicleLoadStatusSettled.
  ///
  /// In ar, this message translates to:
  /// **'مسوّاة'**
  String get vehicleLoadStatusSettled;

  /// No description provided for @myVehicleStockTitle.
  ///
  /// In ar, this message translates to:
  /// **'مخزون مركبتي'**
  String get myVehicleStockTitle;

  /// No description provided for @myVehicleStockNoTrip.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تحميل مفتوح حالياً'**
  String get myVehicleStockNoTrip;

  /// No description provided for @myVehicleStockLoaded.
  ///
  /// In ar, this message translates to:
  /// **'المحمّل'**
  String get myVehicleStockLoaded;

  /// No description provided for @myVehicleStockSold.
  ///
  /// In ar, this message translates to:
  /// **'المباع'**
  String get myVehicleStockSold;

  /// No description provided for @myVehicleStockReturned.
  ///
  /// In ar, this message translates to:
  /// **'المرتجع للمستودع'**
  String get myVehicleStockReturned;

  /// No description provided for @myVehicleStockRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get myVehicleStockRemaining;

  /// No description provided for @myVehicleStockSettle.
  ///
  /// In ar, this message translates to:
  /// **'تسوية نهاية اليوم'**
  String get myVehicleStockSettle;

  /// No description provided for @settlementTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسوية المركبة'**
  String get settlementTitle;

  /// No description provided for @settlementExpected.
  ///
  /// In ar, this message translates to:
  /// **'المتوقع'**
  String get settlementExpected;

  /// No description provided for @settlementActual.
  ///
  /// In ar, this message translates to:
  /// **'الفعلي (العد الفعلي)'**
  String get settlementActual;

  /// No description provided for @settlementDifference.
  ///
  /// In ar, this message translates to:
  /// **'الفرق'**
  String get settlementDifference;

  /// No description provided for @settlementReasonHint.
  ///
  /// In ar, this message translates to:
  /// **'سبب الفرق (اختياري)'**
  String get settlementReasonHint;

  /// No description provided for @settlementSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التسوية'**
  String get settlementSubmit;

  /// No description provided for @settlementSubmittedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال التسوية'**
  String get settlementSubmittedTitle;

  /// No description provided for @settlementStatusNoDiscrepancy.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد فرق'**
  String get settlementStatusNoDiscrepancy;

  /// No description provided for @settlementStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الموافقة'**
  String get settlementStatusPending;

  /// No description provided for @settlementStatusApproved.
  ///
  /// In ar, this message translates to:
  /// **'معتمدة'**
  String get settlementStatusApproved;

  /// No description provided for @settlementApprove.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد التسوية'**
  String get settlementApprove;

  /// No description provided for @settlementsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تسويات'**
  String get settlementsEmpty;

  /// No description provided for @settlementApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد التسوية'**
  String get settlementApproved;

  /// No description provided for @purchaseNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء جديدة'**
  String get purchaseNewTitle;

  /// No description provided for @purchaseSelectSupplier.
  ///
  /// In ar, this message translates to:
  /// **'اختر المورد'**
  String get purchaseSelectSupplier;

  /// No description provided for @purchaseUnitCost.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة الوحدة'**
  String get purchaseUnitCost;

  /// No description provided for @purchaseConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الشراء'**
  String get purchaseConfirm;

  /// No description provided for @purchasesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير شراء'**
  String get purchasesEmpty;

  /// No description provided for @purchaseNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم فاتورة الشراء'**
  String get purchaseNumber;

  /// No description provided for @transferNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحويل مخزون جديد'**
  String get transferNewTitle;

  /// No description provided for @transferFromWarehouse.
  ///
  /// In ar, this message translates to:
  /// **'من مستودع'**
  String get transferFromWarehouse;

  /// No description provided for @transferToWarehouse.
  ///
  /// In ar, this message translates to:
  /// **'إلى مستودع'**
  String get transferToWarehouse;

  /// No description provided for @transferConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التحويل'**
  String get transferConfirm;

  /// No description provided for @transfersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تحويلات'**
  String get transfersEmpty;

  /// No description provided for @adjustmentNewTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسوية مخزون'**
  String get adjustmentNewTitle;

  /// No description provided for @adjustmentQuantityChange.
  ///
  /// In ar, this message translates to:
  /// **'التغيير في الكمية'**
  String get adjustmentQuantityChange;

  /// No description provided for @adjustmentReason.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get adjustmentReason;

  /// No description provided for @adjustmentConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التسوية'**
  String get adjustmentConfirm;

  /// No description provided for @warehouseDocumentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get warehouseDocumentsTitle;

  /// No description provided for @movementsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات مخزون'**
  String get movementsEmpty;

  /// No description provided for @syncStatusTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة المزامنة'**
  String get syncStatusTitle;

  /// No description provided for @syncNow.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة الآن'**
  String get syncNow;

  /// No description provided for @syncNoPending.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات بانتظار المزامنة'**
  String get syncNoPending;

  /// No description provided for @syncFailedBadge.
  ///
  /// In ar, this message translates to:
  /// **'فشلت'**
  String get syncFailedBadge;

  /// No description provided for @syncPendingBadge.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار المزامنة'**
  String get syncPendingBadge;

  /// No description provided for @syncRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get syncRetry;

  /// No description provided for @syncQueuedOffline.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ محلياً — سيتم إرسالها عند توفر الاتصال'**
  String get syncQueuedOffline;

  /// No description provided for @syncCompleted.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت المزامنة'**
  String get syncCompleted;

  /// No description provided for @syncTypeSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get syncTypeSale;

  /// No description provided for @syncTypePayment.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get syncTypePayment;

  /// No description provided for @syncTypeReturn.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get syncTypeReturn;

  /// No description provided for @moreReports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get moreReports;

  /// No description provided for @reportsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reportsTitle;

  /// No description provided for @reportsSales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get reportsSales;

  /// No description provided for @reportsCollections.
  ///
  /// In ar, this message translates to:
  /// **'التحصيلات'**
  String get reportsCollections;

  /// No description provided for @reportsReceivables.
  ///
  /// In ar, this message translates to:
  /// **'الذمم المدينة'**
  String get reportsReceivables;

  /// No description provided for @reportsInventory.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get reportsInventory;

  /// No description provided for @reportsProfit.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get reportsProfit;

  /// No description provided for @reportsSalesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم، حسب التاريخ أو المنتج أو العميل أو المندوب'**
  String get reportsSalesSubtitle;

  /// No description provided for @reportsCollectionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تحصيلات اليوم، حسب المندوب أو العميل'**
  String get reportsCollectionsSubtitle;

  /// No description provided for @reportsReceivablesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أعمار الذمم وأرصدة العملاء'**
  String get reportsReceivablesSubtitle;

  /// No description provided for @reportsInventorySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الحالي، المنخفض، وحركة المخزون'**
  String get reportsInventorySubtitle;

  /// No description provided for @reportsProfitSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات والتكلفة والربح الإجمالي والهامش'**
  String get reportsProfitSubtitle;

  /// No description provided for @reportFrom.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get reportFrom;

  /// No description provided for @reportTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get reportTo;

  /// No description provided for @reportGroupBy.
  ///
  /// In ar, this message translates to:
  /// **'تجميع حسب'**
  String get reportGroupBy;

  /// No description provided for @reportGroupByNone.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get reportGroupByNone;

  /// No description provided for @reportGroupByDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get reportGroupByDate;

  /// No description provided for @reportGroupByProduct.
  ///
  /// In ar, this message translates to:
  /// **'المنتج'**
  String get reportGroupByProduct;

  /// No description provided for @reportGroupByCustomer.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get reportGroupByCustomer;

  /// No description provided for @reportGroupByRepresentative.
  ///
  /// In ar, this message translates to:
  /// **'المندوب'**
  String get reportGroupByRepresentative;

  /// No description provided for @reportInvoiceCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الفواتير'**
  String get reportInvoiceCount;

  /// No description provided for @reportPaymentCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الدفعات'**
  String get reportPaymentCount;

  /// No description provided for @reportTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get reportTotal;

  /// No description provided for @reportNoData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات لهذه الفترة'**
  String get reportNoData;

  /// No description provided for @reportExportPdf.
  ///
  /// In ar, this message translates to:
  /// **'تصدير PDF'**
  String get reportExportPdf;

  /// No description provided for @profitRevenue.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات'**
  String get profitRevenue;

  /// No description provided for @profitCost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة'**
  String get profitCost;

  /// No description provided for @profitGrossProfit.
  ///
  /// In ar, this message translates to:
  /// **'الربح الإجمالي'**
  String get profitGrossProfit;

  /// No description provided for @profitMargin.
  ///
  /// In ar, this message translates to:
  /// **'هامش الربح'**
  String get profitMargin;

  /// No description provided for @receivablesCurrent.
  ///
  /// In ar, this message translates to:
  /// **'الحالي'**
  String get receivablesCurrent;

  /// No description provided for @receivablesDays1to30.
  ///
  /// In ar, this message translates to:
  /// **'1-30 يوم'**
  String get receivablesDays1to30;

  /// No description provided for @receivablesDays31to60.
  ///
  /// In ar, this message translates to:
  /// **'31-60 يوم'**
  String get receivablesDays31to60;

  /// No description provided for @receivablesDays61to90.
  ///
  /// In ar, this message translates to:
  /// **'61-90 يوم'**
  String get receivablesDays61to90;

  /// No description provided for @receivablesOver90.
  ///
  /// In ar, this message translates to:
  /// **'أكثر من 90 يوم'**
  String get receivablesOver90;

  /// No description provided for @receivablesTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get receivablesTotal;

  /// No description provided for @receivablesCustomers.
  ///
  /// In ar, this message translates to:
  /// **'أرصدة العملاء'**
  String get receivablesCustomers;

  /// No description provided for @receivablesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ذمم مستحقة'**
  String get receivablesEmpty;

  /// No description provided for @movementsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حركة المخزون'**
  String get movementsTitle;

  /// No description provided for @movementTypeAll.
  ///
  /// In ar, this message translates to:
  /// **'كل الأنواع'**
  String get movementTypeAll;

  /// No description provided for @movementTypePurchase.
  ///
  /// In ar, this message translates to:
  /// **'شراء'**
  String get movementTypePurchase;

  /// No description provided for @movementTypeSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get movementTypeSale;

  /// No description provided for @movementTypeReturn.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع'**
  String get movementTypeReturn;

  /// No description provided for @movementTypeAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تسوية'**
  String get movementTypeAdjustment;

  /// No description provided for @movementTypeTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل'**
  String get movementTypeTransfer;

  /// No description provided for @movementTypeVehicleLoad.
  ///
  /// In ar, this message translates to:
  /// **'تحميل مركبة'**
  String get movementTypeVehicleLoad;

  /// No description provided for @movementTypeVehicleReturn.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع مركبة'**
  String get movementTypeVehicleReturn;

  /// No description provided for @stockLowStockOnly.
  ///
  /// In ar, this message translates to:
  /// **'المخزون المنخفض فقط'**
  String get stockLowStockOnly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ماتريكس فلسطين';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonLoading => 'جارِ التحميل...';

  @override
  String get commonNoInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get commonSomethingWentWrong => 'حدث خطأ ما. الرجاء المحاولة مرة أخرى';

  @override
  String get commonEmptyTitle => 'لا توجد بيانات';

  @override
  String get commonCurrency => '₪';

  @override
  String get commonOnline => 'متصل';

  @override
  String get commonOffline => 'غير متصل';

  @override
  String get commonLogout => 'تسجيل الخروج';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonPrint => 'طباعة';

  @override
  String get commonView => 'عرض';

  @override
  String get commonCall => 'اتصال';

  @override
  String get commonFrom => 'من';

  @override
  String get commonTo => 'إلى';

  @override
  String get commonFilter => 'تصفية';

  @override
  String get commonNotes => 'ملاحظات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCustomers => 'العملاء';

  @override
  String get navSales => 'المبيعات';

  @override
  String get navCollections => 'التحصيل';

  @override
  String get navMore => 'المزيد';

  @override
  String get navStock => 'المخزون';

  @override
  String get navDocuments => 'المستندات';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'أدخل بياناتك للمتابعة';

  @override
  String get loginUsername => 'اسم المستخدم / البريد الإلكتروني';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginRememberMe => 'تذكرني';

  @override
  String get loginSubmit => 'تسجيل الدخول';

  @override
  String get loginBiometric => 'الدخول ببصمة الإصبع';

  @override
  String get loginBiometricFailed => 'تعذّر التحقق من البصمة. حاول مرة أخرى.';

  @override
  String get loginValidationRequired => 'هذا الحقل مطلوب';

  @override
  String get loginFailedTitle => 'فشل تسجيل الدخول';

  @override
  String get moreProfile => 'الملف الشخصي';

  @override
  String get moreLanguage => 'اللغة';

  @override
  String get moreLanguageArabic => 'العربية';

  @override
  String get moreLanguageEnglish => 'English';

  @override
  String get moreLogoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get dashboardGoodMorning => 'صباح الخير';

  @override
  String get dashboardGoodAfternoon => 'مساء الخير';

  @override
  String get dashboardGoodEvening => 'مساء الخير';

  @override
  String get dashboardTodaySales => 'مبيعات اليوم';

  @override
  String get dashboardCollections => 'التحصيلات';

  @override
  String get dashboardReceivables => 'الذمم المدينة';

  @override
  String get dashboardTodayInvoices => 'فواتير اليوم';

  @override
  String get dashboardQuickActions => 'إجراءات سريعة';

  @override
  String get dashboardNewSale => 'بيع جديد';

  @override
  String get dashboardCollectPayment => 'تحصيل دفعة';

  @override
  String get dashboardReturn => 'مرتجع';

  @override
  String get dashboardMyStock => 'مخزوني';

  @override
  String get dashboardCustomers => 'العملاء';

  @override
  String get dashboardProducts => 'المنتجات';

  @override
  String get dashboardTotalProducts => 'إجمالي المنتجات';

  @override
  String get dashboardLowStock => 'مخزون منخفض';

  @override
  String get dashboardTodayReceipts => 'إضافات اليوم';

  @override
  String get dashboardTodayIssues => 'صرفيات اليوم';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملات بانتظار المزامنة',
      two: 'معاملتان بانتظار المزامنة',
      one: 'معاملة واحدة بانتظار المزامنة',
    );
    return '$_temp0';
  }

  @override
  String get syncedUpToDate => 'تمت المزامنة';

  @override
  String get productFoundTitle => 'تم العثور على المنتج';

  @override
  String get productNotFoundTitle => 'المنتج غير موجود';

  @override
  String get productAvailable => 'المتوفر';

  @override
  String get productSellingPrice => 'سعر البيع';

  @override
  String get productAddToInvoice => 'إضافة إلى الفاتورة';

  @override
  String get productSearchHint => 'بحث عن منتج';

  @override
  String get productScanBarcode => 'مسح الباركود';

  @override
  String get productScanInstruction => 'وجّه الكاميرا نحو الباركود';

  @override
  String get productsEmpty => 'لا توجد منتجات';

  @override
  String get productNewProduct => 'منتج جديد';

  @override
  String get productBarcode => 'الباركود';

  @override
  String get productCategory => 'الفئة';

  @override
  String get productAddCategory => 'إضافة فئة جديدة';

  @override
  String get productBrand => 'الماركة';

  @override
  String get productAddBrand => 'إضافة ماركة جديدة';

  @override
  String get productBaseUnit => 'الوحدة الأساسية';

  @override
  String get productAddUnit => 'إضافة وحدة جديدة';

  @override
  String get productUnitSymbol => 'الرمز (مثال: PC)';

  @override
  String get productReorderLevel => 'حد إعادة الطلب';

  @override
  String get productAddBulkUnit => 'إضافة وحدة بيع أكبر (مثل كرتون)';

  @override
  String get productBulkUnit => 'الوحدة الأكبر';

  @override
  String get productBulkConversion => 'عدد الوحدة الأساسية داخلها';

  @override
  String get productAddOpeningStock => 'إضافة رصيد افتتاحي';

  @override
  String get productOpeningQuantity => 'الكمية الافتتاحية';

  @override
  String get productSave => 'حفظ المنتج';

  @override
  String get productValidationRequired =>
      'الاسم بالإنجليزي والعربي، الوحدة الأساسية، وسعر البيع كلها مطلوبة';

  @override
  String get customerBalance => 'الرصيد';

  @override
  String get customerCreditLimit => 'سقف الائتمان';

  @override
  String get customerNewSale => 'بيع جديد';

  @override
  String get customerPayment => 'دفعة';

  @override
  String get customerStatement => 'كشف حساب';

  @override
  String get customerCall => 'اتصال';

  @override
  String get customerSearchHint => 'الاسم، الهاتف، الرمز، المنطقة';

  @override
  String get customersEmpty => 'لا يوجد عملاء';

  @override
  String get customerTabOverview => 'نظرة عامة';

  @override
  String get customerTabSales => 'المبيعات';

  @override
  String get customerTabPayments => 'الدفعات';

  @override
  String get customerTabStatement => 'كشف الحساب';

  @override
  String get customerAvailableCredit => 'الائتمان المتاح';

  @override
  String get customerOpeningBalance => 'الرصيد الافتتاحي';

  @override
  String get customerClosingBalance => 'الرصيد الحالي';

  @override
  String get customerNoPhone => 'لا يوجد رقم هاتف';

  @override
  String get customerNewCustomer => 'عميل جديد';

  @override
  String get customerFieldName => 'الاسم (إنجليزي)';

  @override
  String get customerFieldNameAr => 'الاسم (عربي)';

  @override
  String get customerFieldPhone => 'الهاتف';

  @override
  String get customerFieldSecondaryPhone => 'هاتف إضافي';

  @override
  String get customerFieldArea => 'المنطقة';

  @override
  String get customerFieldCity => 'المدينة';

  @override
  String get customerFieldAddress => 'العنوان';

  @override
  String get customerFieldCreditLimit => 'سقف الائتمان';

  @override
  String get customerFieldPaymentTerms => 'مدة السداد (أيام)';

  @override
  String get customerSave => 'حفظ العميل';

  @override
  String get customerCreatedTitle => 'تم إضافة العميل';

  @override
  String get customerNameRequired => 'الاسم بالإنجليزي والعربي مطلوبان';

  @override
  String get saleSelectCustomer => 'اختر العميل';

  @override
  String get saleSearchCustomer => 'بحث عن عميل...';

  @override
  String get saleAddProducts => 'إضافة منتجات';

  @override
  String get saleCart => 'السلة';

  @override
  String get saleCartEmpty => 'السلة فارغة';

  @override
  String get saleQuantity => 'الكمية';

  @override
  String get salePrice => 'السعر';

  @override
  String get saleTotal => 'الإجمالي';

  @override
  String get saleSubtotal => 'المجموع الفرعي';

  @override
  String get saleDiscount => 'الخصم';

  @override
  String get salePaid => 'المدفوع';

  @override
  String get saleRemaining => 'المتبقي';

  @override
  String get salePaymentMethod => 'طريقة الدفع';

  @override
  String get salePaymentCash => 'نقدي';

  @override
  String get salePaymentBankTransfer => 'تحويل بنكي';

  @override
  String get salePaymentCheque => 'شيك';

  @override
  String get salePaymentCredit => 'آجل';

  @override
  String get salePaymentPartial => 'دفعة جزئية';

  @override
  String get saleConfirm => 'تأكيد البيع';

  @override
  String get saleReview => 'مراجعة الفاتورة';

  @override
  String get saleCompletedTitle => 'تم إنجاز عملية البيع';

  @override
  String get saleInvoiceNumber => 'رقم الفاتورة';

  @override
  String get saleViewInvoice => 'عرض الفاتورة';

  @override
  String get saleNewSale => 'بيع جديد';

  @override
  String get saleSharePdf => 'مشاركة PDF';

  @override
  String get salesEmpty => 'لا توجد فواتير';

  @override
  String get saleStatusConfirmed => 'مؤكدة';

  @override
  String get saleStatusCancelled => 'ملغاة';

  @override
  String get saleNextStep => 'التالي';

  @override
  String get saleBackStep => 'السابق';

  @override
  String get saleMustSelectCustomer => 'الرجاء اختيار عميل';

  @override
  String get saleMustAddProduct => 'الرجاء إضافة منتج واحد على الأقل';

  @override
  String get paymentCurrentBalance => 'الرصيد الحالي';

  @override
  String get paymentAmount => 'مبلغ الدفعة';

  @override
  String get paymentReference => 'المرجع';

  @override
  String get paymentConfirm => 'تأكيد الدفعة';

  @override
  String get paymentRecordedTitle => 'تم تسجيل الدفعة';

  @override
  String get paymentPreviousBalance => 'الرصيد السابق';

  @override
  String get paymentNewBalance => 'الرصيد الجديد';

  @override
  String get paymentsEmpty => 'لا توجد دفعات';

  @override
  String get paymentSelectCustomerFirst => 'الرجاء اختيار عميل أولاً';

  @override
  String get stockAvailable => 'الكمية المتوفرة';

  @override
  String get stockLowBadge => 'منخفض';

  @override
  String get stockEmpty => 'لا توجد بيانات مخزون';

  @override
  String get moreVersion => 'الإصدار';

  @override
  String get returnSelectInvoice => 'اختر الفاتورة';

  @override
  String get returnSelectProducts => 'اختر المنتجات المرتجعة';

  @override
  String get returnQuantity => 'الكمية المرتجعة';

  @override
  String get returnMaxReturnable => 'الحد الأقصى للإرجاع';

  @override
  String get returnConfirm => 'تأكيد المرتجع';

  @override
  String get returnCompletedTitle => 'تم تسجيل المرتجع';

  @override
  String get returnsEmpty => 'لا توجد مرتجعات';

  @override
  String get returnNumber => 'رقم المرتجع';

  @override
  String get returnNewReturn => 'مرتجع جديد';

  @override
  String get vehicleLoadNewTitle => 'تحميل مركبة جديد';

  @override
  String get vehicleLoadSelectVehicle => 'اختر المركبة';

  @override
  String get vehicleLoadSelectRep => 'اختر المندوب';

  @override
  String get vehicleLoadSelectWarehouse => 'اختر المستودع';

  @override
  String get vehicleLoadAddProduct => 'إضافة منتج';

  @override
  String get vehicleLoadConfirm => 'تأكيد التحميل';

  @override
  String get vehicleLoadCompletedTitle => 'تم تحميل المركبة';

  @override
  String get vehicleLoadsEmpty => 'لا توجد تحميلات';

  @override
  String get vehicleLoadNumber => 'رقم التحميل';

  @override
  String get vehicleLoadStatusLoaded => 'محمّلة';

  @override
  String get vehicleLoadStatusSettled => 'مسوّاة';

  @override
  String get myVehicleStockTitle => 'مخزون مركبتي';

  @override
  String get myVehicleStockNoTrip => 'لا يوجد تحميل مفتوح حالياً';

  @override
  String get myVehicleStockLoaded => 'المحمّل';

  @override
  String get myVehicleStockSold => 'المباع';

  @override
  String get myVehicleStockReturned => 'المرتجع للمستودع';

  @override
  String get myVehicleStockRemaining => 'المتبقي';

  @override
  String get myVehicleStockSettle => 'تسوية نهاية اليوم';

  @override
  String get settlementTitle => 'تسوية المركبة';

  @override
  String get settlementExpected => 'المتوقع';

  @override
  String get settlementActual => 'الفعلي (العد الفعلي)';

  @override
  String get settlementDifference => 'الفرق';

  @override
  String get settlementReasonHint => 'سبب الفرق (اختياري)';

  @override
  String get settlementSubmit => 'إرسال التسوية';

  @override
  String get settlementSubmittedTitle => 'تم إرسال التسوية';

  @override
  String get settlementStatusNoDiscrepancy => 'لا يوجد فرق';

  @override
  String get settlementStatusPending => 'بانتظار الموافقة';

  @override
  String get settlementStatusApproved => 'معتمدة';

  @override
  String get settlementApprove => 'اعتماد التسوية';

  @override
  String get settlementsEmpty => 'لا توجد تسويات';

  @override
  String get settlementApproved => 'تم اعتماد التسوية';

  @override
  String get purchaseNewTitle => 'فاتورة شراء جديدة';

  @override
  String get purchaseSelectSupplier => 'اختر المورد';

  @override
  String get purchaseUnitCost => 'تكلفة الوحدة';

  @override
  String get purchaseConfirm => 'تأكيد الشراء';

  @override
  String get purchasesEmpty => 'لا توجد فواتير شراء';

  @override
  String get purchaseNumber => 'رقم فاتورة الشراء';

  @override
  String get transferNewTitle => 'تحويل مخزون جديد';

  @override
  String get transferFromWarehouse => 'من مستودع';

  @override
  String get transferToWarehouse => 'إلى مستودع';

  @override
  String get transferConfirm => 'تأكيد التحويل';

  @override
  String get transfersEmpty => 'لا توجد تحويلات';

  @override
  String get adjustmentNewTitle => 'تسوية مخزون';

  @override
  String get adjustmentQuantityChange => 'التغيير في الكمية';

  @override
  String get adjustmentReason => 'السبب';

  @override
  String get adjustmentConfirm => 'تأكيد التسوية';

  @override
  String get warehouseDocumentsTitle => 'المستندات';

  @override
  String get movementsEmpty => 'لا توجد حركات مخزون';

  @override
  String get syncStatusTitle => 'حالة المزامنة';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get syncNoPending => 'لا توجد معاملات بانتظار المزامنة';

  @override
  String get syncFailedBadge => 'فشلت';

  @override
  String get syncPendingBadge => 'بانتظار المزامنة';

  @override
  String get syncRetry => 'إعادة المحاولة';

  @override
  String get syncQueuedOffline =>
      'تم الحفظ محلياً — سيتم إرسالها عند توفر الاتصال';

  @override
  String get syncCompleted => 'اكتملت المزامنة';

  @override
  String get syncTypeSale => 'بيع';

  @override
  String get syncTypePayment => 'دفعة';

  @override
  String get syncTypeReturn => 'مرتجع';

  @override
  String get moreReports => 'التقارير';

  @override
  String get reportsTitle => 'التقارير';

  @override
  String get reportsSales => 'المبيعات';

  @override
  String get reportsCollections => 'التحصيلات';

  @override
  String get reportsReceivables => 'الذمم المدينة';

  @override
  String get reportsInventory => 'المخزون';

  @override
  String get reportsProfit => 'الأرباح';

  @override
  String get reportsSalesSubtitle =>
      'مبيعات اليوم، حسب التاريخ أو المنتج أو العميل أو المندوب';

  @override
  String get reportsCollectionsSubtitle =>
      'تحصيلات اليوم، حسب المندوب أو العميل';

  @override
  String get reportsReceivablesSubtitle => 'أعمار الذمم وأرصدة العملاء';

  @override
  String get reportsInventorySubtitle =>
      'المخزون الحالي، المنخفض، وحركة المخزون';

  @override
  String get reportsProfitSubtitle =>
      'الإيرادات والتكلفة والربح الإجمالي والهامش';

  @override
  String get reportFrom => 'من';

  @override
  String get reportTo => 'إلى';

  @override
  String get reportGroupBy => 'تجميع حسب';

  @override
  String get reportGroupByNone => 'الإجمالي';

  @override
  String get reportGroupByDate => 'التاريخ';

  @override
  String get reportGroupByProduct => 'المنتج';

  @override
  String get reportGroupByCustomer => 'العميل';

  @override
  String get reportGroupByRepresentative => 'المندوب';

  @override
  String get reportInvoiceCount => 'عدد الفواتير';

  @override
  String get reportPaymentCount => 'عدد الدفعات';

  @override
  String get reportTotal => 'الإجمالي';

  @override
  String get reportNoData => 'لا توجد بيانات لهذه الفترة';

  @override
  String get reportExportPdf => 'تصدير PDF';

  @override
  String get profitRevenue => 'الإيرادات';

  @override
  String get profitCost => 'التكلفة';

  @override
  String get profitGrossProfit => 'الربح الإجمالي';

  @override
  String get profitMargin => 'هامش الربح';

  @override
  String get receivablesCurrent => 'الحالي';

  @override
  String get receivablesDays1to30 => '1-30 يوم';

  @override
  String get receivablesDays31to60 => '31-60 يوم';

  @override
  String get receivablesDays61to90 => '61-90 يوم';

  @override
  String get receivablesOver90 => 'أكثر من 90 يوم';

  @override
  String get receivablesTotal => 'الإجمالي';

  @override
  String get receivablesCustomers => 'أرصدة العملاء';

  @override
  String get receivablesEmpty => 'لا توجد ذمم مستحقة';

  @override
  String get movementsTitle => 'حركة المخزون';

  @override
  String get movementTypeAll => 'كل الأنواع';

  @override
  String get movementTypePurchase => 'شراء';

  @override
  String get movementTypeSale => 'بيع';

  @override
  String get movementTypeReturn => 'مرتجع';

  @override
  String get movementTypeAdjustment => 'تسوية';

  @override
  String get movementTypeTransfer => 'تحويل';

  @override
  String get movementTypeVehicleLoad => 'تحميل مركبة';

  @override
  String get movementTypeVehicleReturn => 'مرتجع مركبة';

  @override
  String get stockLowStockOnly => 'المخزون المنخفض فقط';
}

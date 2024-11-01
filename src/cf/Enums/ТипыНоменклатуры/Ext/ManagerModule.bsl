﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

// Возвращает текст подсказки по типу номенклатуры
//
// Параметры:
//  ТипНоменклатуры	 - ПеречислениеСсылка.ТипыНоменклатуры	 - тип номенклатуры.
// 
// Возвращаемое значение:
//  Строка - подсказка по типу номенклатуры.
//
Функция ПодсказкаПоТипуНоменклатуры(ТипНоменклатуры) Экспорт
	
	Если ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Товар Тогда
		Возврат НСтр("ru = 'Материальные ценности, которые закупаются, производятся, реализуются предприятием и учитываются на складах. Возможен контроль остатков на складах, учет себестоимости, обеспечение потребностей и др.';
					|en = 'Tangible assets purchased, produced, sold by the enterprise and recorded in warehouses. It is possible to control stock, keep records of cost, satisfy demands, etc.'");
	ИначеЕсли ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Набор Тогда
		ТекстПодсказки = НСтр("ru = 'Комплекты, которые не хранятся на складе, а собираются динамически. Используются для удобного выбора связанных позиций в документах продажи, ценообразовании и печати.';
								|en = 'Sets that are not stored in the warehouse but assembled dynamically. They are used to easily select linked items in sales documents, pricing, and printing.'");
		//++ НЕ УТ
		ТекстПодсказки = НСтр("ru = 'Комплекты, которые не хранятся на складе, а собираются динамически. Используются для удобного выбора связанных позиций в ресурсных спецификациях, документах продажи, ценообразовании и печати.';
								|en = 'Sets that are not stored in the warehouse but assembled dynamically. They are used to easily select linked items in bills of materials, sales documents, pricing, and printing.'");
		//-- НЕ УТ
		Возврат ТекстПодсказки;
	ИначеЕсли ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Услуга Тогда
		Возврат НСтр("ru = 'Нематериальные ценности, которые закупаются предприятием или реализуются клиентам. Для услуг не ведется учет себестоимости. В момент приобретения услуги указывается статья расходов, определяющая дальнейший учет расходов.';
					|en = 'Intangible assets purchased by the enterprise or sold to the customers. There is no cost accounting for services. When a service is purchased, an expense item for accounting purposes is specified.'");
	ИначеЕсли ТипНоменклатуры = Перечисления.ТипыНоменклатуры.Работа Тогда
		Возврат НСтр("ru = 'Нематериальные ценности, которые закупаются или производятся, реализуются клиентам и учитываются в подразделении-получателе. Ведется количественный учет и учет себестоимости.';
					|en = 'Intangible assets purchased or produced, sold to customers and recorded in the receiving business unit. Quantitative and cost accounting records are kept.'");
	ИначеЕсли ТипНоменклатуры = Перечисления.ТипыНоменклатуры.МногооборотнаяТара Тогда
		Возврат НСтр("ru = 'Тара, которая учитывается отдельно на складе и может возвращаться поставщику товаров или передаваться на условиях возврата клиенту.';
					|en = 'Package recorded separately in a warehouse and can be returned to goods vendor or transferred to a customer according to return terms.'");
	Иначе
		Возврат НСтр("ru = 'Определяет возможности по учету номенклатуры в различных механизмах';
					|en = 'Determines whether products can be accounted for in different tools'");
	КонецЕсли;	
	
КонецФункции

#КонецОбласти

#КонецЕсли

#Область ОбработчикиСобытий

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	ИспользоватьМногооборотнуюТару = ПолучитьФункциональнуюОпцию("ИспользоватьМногооборотнуюТару");
	ИспользоватьНаборы = ПолучитьФункциональнуюОпцию("ИспользоватьНаборы");
	НесколькоВидовНоменклатуры = ПолучитьФункциональнуюОпцию("ИспользоватьНесколькоВидовНоменклатуры");
	ЭтоБазовая = ПолучитьФункциональнуюОпцию("БазоваяВерсия");
	
	СтандартнаяОбработка = Ложь;
	ДанныеВыбора = Новый СписокЗначений();
	Для Каждого ТекЭлемент Из Перечисления.ТипыНоменклатуры Цикл
		Если ТекЭлемент = Перечисления.ТипыНоменклатуры.МногооборотнаяТара
			И (Не ИспользоватьМногооборотнуюТару ИЛИ Не НесколькоВидовНоменклатуры) Тогда
			Продолжить;
		ИначеЕсли ТекЭлемент = Перечисления.ТипыНоменклатуры.Набор
			И (Не ИспользоватьНаборы ИЛИ Не НесколькоВидовНоменклатуры) Тогда
			Продолжить;
		ИначеЕсли ТекЭлемент = Перечисления.ТипыНоменклатуры.Работа
			И (Не НесколькоВидовНоменклатуры ИЛИ ЭтоБазовая) Тогда
			Продолжить;
		Иначе
			ДанныеВыбора.Добавить(ТекЭлемент);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

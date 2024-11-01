﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Владелец = Неопределено;
	
	Если Параметры.Свойство("Отбор") 
		И Параметры.Отбор.Свойство("Владелец") Тогда

		Владелец = Параметры.Отбор.Владелец;

	КонецЕсли;	
	
	Если Владелец <> Справочники.НаборыУпаковок.БазовыеЕдиницыИзмерения Тогда
		ТекстИсключения = НСтр("ru = 'Форма предназначена для отображения только списка единиц упаковок.';
								|en = 'The form is supposed to contain only packaging units.'");
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;	
	Элементы.ПодобратьИзКлассификатора.Видимость = ПравоДоступа("Добавление", Метаданные.Справочники.УпаковкиЕдиницыИзмерения);
	// СтандартныеПодсистемы.БазоваяФункциональность
	МультиязычностьСервер.ИзменениеТекстаЗапросаСпискаДляТекущегоЯзыка(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.БазоваяФункциональность
	СобытияФорм.ПриСозданииНаСервере(ЭтаФорма, Отказ, СтандартнаяОбработка);

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПодобратьИзКлассификатора(Команда)
	
	ОткрытьФорму("Справочник.УпаковкиЕдиницыИзмерения.Форма.КлассификаторЕдиницИзмерения",
				,
				,
				,
				,
				,
				Новый ОписаниеОповещения("ПодобратьИзКлассификатораЗавершение", ЭтотОбъект),
				РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодобратьИзКлассификатораЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если ТипЗнч(Результат) = Тип("Структура")
		И Результат.Свойство("КоличествоНовыхЭлементов") Тогда
		
		НоменклатураКлиент.ОповеститьОбИзмененииСпискаВыбораЕдиницИзмерения(Результат.КоличествоНовыхЭлементов,
			Результат.НовыеЭлементы);
		
	КонецЕсли;
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ВыполнитьПереопределяемуюКоманду(Команда)
	
	СобытияФормКлиент.ВыполнитьПереопределяемуюКоманду(ЭтаФорма, Команда);
	
КонецПроцедуры

#КонецОбласти

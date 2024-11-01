﻿#Если НЕ МобильныйАвтономныйСервер Тогда
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	ОбновлениеИнформационнойБазы.ПроверитьОбъектОбработан(ЭтотОбъект);

	Справочники.УпаковкиЕдиницыИзмерения.ОтработатьЛогикуСвязиРеквизитов(ЭтотОбъект);
	
	Если ТипИзмеряемойВеличины <> Перечисления.ТипыИзмеряемыхВеличин.Упаковка Тогда
		Возврат;
	КонецЕсли;
	
	Если ЭтоНовый() Тогда
		ДополнительныеСвойства.Вставить("НужноОбновитьВариантыПереупаковки", Истина);
		ДополнительныеСвойства.Вставить("ЭтоНовый", Истина);
		ДополнительныеСвойства.Вставить("ПоменялсяКоэффициент", Ложь);
		ДополнительныеСвойства.Вставить("ПоменялсяРодитель", Ложь);
		ДополнительныеСвойства.Вставить("БывшийРодитель", Неопределено);
	Иначе
		
		ДополнительныеСвойства.Вставить("ЭтоНовый", Ложь);
		
		РеквизитыДоЗаписи = Справочники.УпаковкиЕдиницыИзмерения.КоэффициентВесОбъемПрочиеРеквизитыУпаковки(Ссылка,
			Неопределено,
			"Родитель, Числитель, Знаменатель, КоличествоУпаковок, ПометкаУдаления");
		
		ПоменялсяКоэффициент = РеквизитыДоЗаписи.Числитель <> Числитель
							Или РеквизитыДоЗаписи.Знаменатель <> Знаменатель
							Или РеквизитыДоЗаписи.КоличествоУпаковок <> КоличествоУпаковок;
		
		Если РеквизитыДоЗаписи.Родитель <> Родитель
			Или ПоменялсяКоэффициент
			Или ПометкаУдаления <> РеквизитыДоЗаписи.ПометкаУдаления Тогда
			
			ДополнительныеСвойства.Вставить("ПоменялсяКоэффициент", ПоменялсяКоэффициент);
			ДополнительныеСвойства.Вставить("ПоменялсяРодитель", РеквизитыДоЗаписи.Родитель <> Родитель);
			ДополнительныеСвойства.Вставить("НужноОбновитьВариантыПереупаковки", Истина);
			
			Если ДополнительныеСвойства.ПоменялсяРодитель Тогда
				ДополнительныеСвойства.Вставить("БывшийРодитель", РеквизитыДоЗаписи.Родитель);
			Иначе
				ДополнительныеСвойства.Вставить("БывшийРодитель", Неопределено);
			КонецЕсли;
			
		Иначе
			ДополнительныеСвойства.Вставить("НужноОбновитьВариантыПереупаковки", Ложь);
			ДополнительныеСвойства.Вставить("ПоменялсяКоэффициент", Ложь);
			ДополнительныеСвойства.Вставить("ПоменялсяРодитель", Ложь);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод
	|ИЗ
	|	РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
	|ГДЕ
	|	ШтрихкодыНоменклатуры.Упаковка = &Упаковка";
	
	Запрос.УстановитьПараметр("Упаковка", Ссылка);
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		НаборЗаписей = РегистрыСведений.ШтрихкодыНоменклатуры.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Штрихкод.Значение = Выборка.Штрихкод;
		НаборЗаписей.Отбор.Штрихкод.Использование = Истина;
		НаборЗаписей.Записать();
	КонецЦикла;
	
	// Корректировка регистра сведений "ВариантыПереупаковки"
	Запрос.Текст =
	"ВЫБРАТЬ
	|	УпаковкиЕдиницыИзмерения.Ссылка
	|ИЗ
	|	Справочник.УпаковкиЕдиницыИзмерения КАК УпаковкиЕдиницыИзмерения
	|ГДЕ
	|	УпаковкиЕдиницыИзмерения.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Родитель);
	СтарыеМаксимальныеУпаковки = Новый Массив;
	
	Если НЕ Родитель.Пустая() Тогда
		
		Если Не Запрос.Выполнить().Пустой()
			И Не ЕстьВариантыПереупаковки(Родитель) Тогда
			
			НаборЗаписей = РегистрыСведений.ВариантыПереупаковки.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Упаковка.Установить(Ссылка);
			НаборЗаписей.Прочитать();
			
			Если НаборЗаписей.Количество() <> 0 Тогда
				
				СтараяМаксимальнаяУпаковка = НаборЗаписей[0].МаксимальнаяУпаковкаВВетви;
				
				// Заменить Максимальную упаковку старую на новую
				НаборЗаписей = РегистрыСведений.ВариантыПереупаковки.СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.МаксимальнаяУпаковкаВВетви.Установить(СтараяМаксимальнаяУпаковка);
				НаборЗаписей.Прочитать();
				ТаблицаРегистра = НаборЗаписей.Выгрузить();
				
				НаборЗаписей = РегистрыСведений.ВариантыПереупаковки.СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.МаксимальнаяУпаковкаВВетви.Установить(Родитель);
				НаборЗаписей.Прочитать();
				ТаблицаРегистра.ЗаполнитьЗначения(Родитель,"МаксимальнаяУпаковкаВВетви");
				НаборЗаписей.Загрузить(ТаблицаРегистра);
				НаборЗаписей.Записать();
				
				// Добавить запись с пустым источником
				НаборЗаписей.Отбор.МаксимальнаяУпаковкаВВетви.Установить(Родитель);
				НаборЗаписей.Отбор.Источник.Установить(Справочники.УпаковкиЕдиницыИзмерения.ПустаяСсылка());
				НаборЗаписей.Отбор.Упаковка.Установить(Родитель);
				НаборЗаписей.Прочитать();
				
				НоваяЗапись = НаборЗаписей.Добавить();
				НоваяЗапись.Упаковка = Родитель;
				НоваяЗапись.МаксимальнаяУпаковкаВВетви = Родитель;
				НаборЗаписей.Записать();
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ДанныеЗаполнения <> Неопределено Тогда 
		
		Если ДанныеЗаполнения.Свойство("ТипИзмеряемойВеличины",ТипИзмеряемойВеличины)
			И ТипИзмеряемойВеличины = Перечисления.ТипыИзмеряемыхВеличин.Упаковка Тогда
			
			Если (Не ДанныеЗаполнения.Свойство("Владелец",Владелец)
				Или Не ЗначениеЗаполнено(Владелец)) Тогда
				
				ТекстИсключения = НСтр("ru = 'Упаковку нужно создавать из формы номенклатуры или набора упаковок.';
										|en = 'To create a packaging unit, open an item form or a packaging group.'");
				
				ВызватьИсключение ТекстИсключения;
				
			КонецЕсли;
			
			Если ТипЗнч(ДанныеЗаполнения.Владелец) = Тип("СправочникСсылка.Номенклатура") Тогда
				ЗначениеРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДанныеЗаполнения.Владелец, "ИспользоватьУпаковки,НаборУпаковок");
				Если Не ЗначениеРеквизитов.ИспользоватьУпаковки Тогда
					ТекстИсключения = НСтр("ru = 'В карточке номенклатуры %Номенклатура% не включено использование упаковок. Создание упаковки невозможно.';
											|en = 'Packaging units are disabled for %Номенклатура%. Cannot create a packaging unit.'");
					ТекстИсключения = СтрЗаменить(ТекстИсключения, "%Номенклатура%", Строка(ДанныеЗаполнения.Владелец));
					
					ВызватьИсключение ТекстИсключения;
				КонецЕсли;
				
				Если ЗначениеРеквизитов.НаборУпаковок <> Справочники.НаборыУпаковок.ИндивидуальныйДляНоменклатуры Тогда
					Владелец = ЗначениеРеквизитов.НаборУпаковок;
				Иначе
					Владелец = ДанныеЗаполнения.Владелец;
				КонецЕсли;
			КонецЕсли;
			
			Если ДанныеЗаполнения.Свойство("Родитель", Родитель)
				И ЗначениеЗаполнено(Родитель) Тогда
				
				ТипУпаковкиРодителя = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Родитель, "ТипУпаковки");
				
				Если ТипУпаковкиРодителя = Перечисления.ТипыУпаковокНоменклатуры.ТоварноеМесто Тогда 
					
					СтандартнаяОбработка = Ложь;
					ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.ТоварноеМесто;
					Родитель    = Справочники.УпаковкиЕдиницыИзмерения.ПустаяСсылка();
					
				Иначе
					
					ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.Составная;
					
				КонецЕсли;
				
			КонецЕсли;
			
			СкладскаяГруппа = ЗначениеНастроекПовтИсп.СкладскаяГруппаУпаковокПоУмолчанию(СкладскаяГруппа);
			ЕдиницаИзмерения = Справочники.УпаковкиЕдиницыИзмерения.ПустаяСсылка();
			
			ЕдиницаДлины = Константы.ЕдиницаИзмеренияДлины.Получить();
			
			ГлубинаЕдиницаИзмерения = ЕдиницаДлины;
			ШиринаЕдиницаИзмерения  = ЕдиницаДлины;
			ВысотаЕдиницаИзмерения  = ЕдиницаДлины;
			
			ОбъемЕдиницаИзмерения   = Константы.ЕдиницаИзмеренияОбъема.Получить();
			ВесЕдиницаИзмерения     = Константы.ЕдиницаИзмеренияВеса.Получить();
		Иначе
			Владелец = Справочники.НаборыУпаковок.БазовыеЕдиницыИзмерения;
		КонецЕсли;
		
	Иначе
		Владелец = Справочники.НаборыУпаковок.БазовыеЕдиницыИзмерения;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	МассивНепроверяемыхРеквизитов = Новый Массив;
	
	Если ТипИзмеряемойВеличины <> Перечисления.ТипыИзмеряемыхВеличин.Упаковка Тогда
		
		МассивНепроверяемыхРеквизитов.Добавить("ЕдиницаИзмерения");
		МассивНепроверяемыхРеквизитов.Добавить("Родитель");
		МассивНепроверяемыхРеквизитов.Добавить("КоличествоУпаковок");
		МассивНепроверяемыхРеквизитов.Добавить("НоменклатураМногооборотнаяТара");
		МассивНепроверяемыхРеквизитов.Добавить("ХарактеристикаМногооборотнаяТара");
		МассивНепроверяемыхРеквизитов.Добавить("ТипУпаковки");
		
		Если ТипИзмеряемойВеличины = Перечисления.ТипыИзмеряемыхВеличин.КоличествоШтук
			Или Не ЗначениеЗаполнено(ТипИзмеряемойВеличины) Тогда
			
			МассивНепроверяемыхРеквизитов.Добавить("Числитель");
			МассивНепроверяемыхРеквизитов.Добавить("Знаменатель");
			
		КонецЕсли;
		
	Иначе
		
		СтруктураРеквизитов = Новый Структура;
		СтруктураРеквизитов.Вставить("ЕдиницаИзмерения", "ЕдиницаИзмерения");
		
		Если ТипЗнч(Владелец) = Тип("СправочникСсылка.Номенклатура") Тогда
			СтруктураРеквизитов.Вставить("НаборУпаковок", "НаборУпаковок");
			СтруктураРеквизитов.Вставить("ТипНоменклатуры", "ТипНоменклатуры");
		Иначе // если владелец-тип справочник НаборыУпаковок.
			СтруктураРеквизитов.Вставить("НаборУпаковок", "Ссылка");
		КонецЕсли;
		
		ЗначенияРеквизитовВладельца = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Владелец, СтруктураРеквизитов);
		
		Если ТипЗнч(Владелец) = Тип("СправочникСсылка.Номенклатура") Тогда
			
			Если ЗначенияРеквизитовВладельца.НаборУпаковок <> Справочники.НаборыУпаковок.ИндивидуальныйДляНоменклатуры Тогда
				
				ТекстСообщения = НСтр("ru = 'Для номенклатуры %Владелец% выбран набор упаковок ""%ТекущееЗначение%"", 
					|поэтому все упаковки должны подчиняться набору упаковок, а не номенклатуре';
					|en = 'The ""%ТекущееЗначение%"" packaging group is selected for the %Владелец% items, 
					|so all packaging units must be subordinate to the packaging group, not the items'");
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Владелец%", Строка(Владелец));
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ТекущееЗначение%", Строка(ЗначенияРеквизитовВладельца.НаборУпаковок));
				
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, "Владелец", , Отказ);
				
			КонецЕсли;
			
			Если ЗначенияРеквизитовВладельца.ТипНоменклатуры <> Перечисления.ТипыНоменклатуры.Товар Тогда
				
				ТекстСообщения = НСтр("ru = 'Номенклатура %Владелец% не является товаром. Упаковки ведутся только для товаров.';
										|en = '%Владелец% is not inventory. Only inventory can have packaging units.'");
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Владелец%", Строка(Владелец));
				
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, "Владелец",, Отказ);
				
			КонецЕсли;
			
		Иначе // если владелец-тип справочник НаборыУпаковок.
			
			Если ЗначенияРеквизитовВладельца.НаборУпаковок = Справочники.НаборыУпаковок.ИндивидуальныйДляНоменклатуры Тогда
				
				ТекстСообщения = НСтр("ru = 'Для номенклатуры %Владелец% выбран набор упаковок ""%ТекущееЗначение%"",
					|поэтому все упаковки должны подчиняться номенклатуре, а не набору упаковок';
					|en = 'The ""%ТекущееЗначение%"" packaging group is selected for the %Владелец% items 
					|so all packaging units must be subordinate to the items, not the packaging group'");
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Владелец%", Строка(Владелец));
				ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ТекущееЗначение%", Строка(ЗначенияРеквизитовВладельца.НаборУпаковок));
				
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, ЭтотОбъект, "Владелец", , Отказ);
				
			КонецЕсли;
			
		КонецЕсли;
		
		ЗначенияРеквизитовДоЗаписи = Справочники.УпаковкиЕдиницыИзмерения.КоэффициентВесОбъемПрочиеРеквизитыУпаковки(Ссылка,
			Неопределено,
			"Родитель");
		
		Если Не ЭтоНовый()
			И ЗначенияРеквизитовДоЗаписи.Родитель <> Родитель
			И Не ДополнительныеСвойства.Свойство("РазрешенаСменаРодителя") Тогда
			
			ТекстСообщения = НСтр("ru = 'Родителя можно менять только из формы элемента.';
									|en = 'You can change the parent item only from the item form.'");
			
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , ,Отказ);
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Родитель) Тогда
			
			ЗначенияРеквизитовРодителя = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Родитель, "ТипИзмеряемойВеличины, 
				|ТипУпаковки");
			
			Если ЗначенияРеквизитовРодителя.ТипИзмеряемойВеличины <> Перечисления.ТипыИзмеряемыхВеличин.Упаковка Тогда
				
				ТекстСообщения = НСтр("ru = 'Нельзя подчинять упаковки единицам измерения';
										|en = 'Packaging units cannot be subordinate to a unit of measure.'");
				
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , , Отказ);
				
			КонецЕсли;
			
			Если ЗначенияРеквизитовРодителя.ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.Разупаковка Тогда
				ТекстСообщения = НСтр("ru = 'Разупаковки нельзя упаковывать.';
										|en = 'No repackaging after disassembly.'");
				
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		
		Если ПоставляетсяВМногооборотнойТаре Тогда
			
			Если ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.Составная
				И МинимальноеКоличествоУпаковокМногооборотнойТары > КоличествоУпаковок Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					НСтр("ru = 'Минимальное количество упаковок многооборотной тары не может быть больше количества упаковок.';
						|en = 'The minimum number of reusable packaging units cannot exceed the total number of packaging units.'"),
					,
					"Объект.МинимальноеКоличествоУпаковокМногооборотнойТары",
					,
					Отказ);
			
			ИначеЕсли ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.Конечная
				И МинимальноеКоличествоУпаковокМногооборотнойТары > Числитель Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					НСтр("ru = 'Минимальное количество упаковок многооборотной тары не может быть больше количества единиц измерения 
						|по классификатору.';
						|en = 'The minimum number of reusable packaging units cannot exceed
						|the number of units of measure in the classifier.'"),
					,
					"Объект.МинимальноеКоличествоУпаковокМногооборотнойТары",
					,
					Отказ);
					
			КонецЕсли;
			
		КонецЕсли;
		
		Если ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.Разупаковка
			И Справочники.УпаковкиЕдиницыИзмерения.ЭтоМернаяЕдиница(ЗначенияРеквизитовВладельца.ЕдиницаИзмерения) Тогда
			
			ОбщегоНазначения.СообщитьПользователю(
				НСтр("ru = 'Товар измеряется в мерной единице измерения - такую единицу нельзя разупаковывать.';
					|en = 'Goods are measured in units of measure, such item cannot be repacked.'"),
				,
				"Объект.ТипУпаковки",
				,
				Отказ);
			
		КонецЕсли;
		
		Если ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.Конечная Тогда
			МассивНепроверяемыхРеквизитов.Добавить("Родитель");
			МассивНепроверяемыхРеквизитов.Добавить("КоличествоУпаковок");
			МассивНепроверяемыхРеквизитов.Добавить("Знаменатель");
		ИначеЕсли ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.Составная Тогда
			МассивНепроверяемыхРеквизитов.Добавить("Числитель");
			МассивНепроверяемыхРеквизитов.Добавить("Знаменатель");
		ИначеЕсли ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.Разупаковка Тогда
			МассивНепроверяемыхРеквизитов.Добавить("Родитель");
			МассивНепроверяемыхРеквизитов.Добавить("КоличествоУпаковок");
			МассивНепроверяемыхРеквизитов.Добавить("Числитель");
		ИначеЕсли ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.ТоварноеМесто Тогда
			МассивНепроверяемыхРеквизитов.Добавить("Родитель");
			МассивНепроверяемыхРеквизитов.Добавить("Числитель");
			МассивНепроверяемыхРеквизитов.Добавить("Знаменатель");
		КонецЕсли;
		
		Если Не ПоставляетсяВМногооборотнойТаре Тогда
			МассивНепроверяемыхРеквизитов.Добавить("НоменклатураМногооборотнаяТара");
			МассивНепроверяемыхРеквизитов.Добавить("ХарактеристикаМногооборотнаяТара");
		ИначеЕсли Не Справочники.Номенклатура.ХарактеристикиИспользуются(НоменклатураМногооборотнаяТара) Тогда
			МассивНепроверяемыхРеквизитов.Добавить("ХарактеристикаМногооборотнаяТара");
		КонецЕсли;
		
	КонецЕсли;
	
	ПроверитьКратностьЧисловыхРеквизитов(Отказ);
	
	ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНепроверяемыхРеквизитов);
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипИзмеряемойВеличины = Перечисления.ТипыИзмеряемыхВеличин.Упаковка Тогда
		Если ДополнительныеСвойства.НужноОбновитьВариантыПереупаковки Тогда
			ОбновитьВариантыПереупаковки();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ПриЧтенииПредставленийНаСервере() Экспорт
	// СтандартныеПодсистемы.БазоваяФункциональность
	МультиязычностьСервер.ПриЧтенииПредставленийНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.БазоваяФункциональность
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЕстьВариантыПереупаковки(РодительСсылка)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	
	"ВЫБРАТЬ
	|	ВариантыПереупаковки.Упаковка,
	|	ВариантыПереупаковки.Источник,
	|	ВариантыПереупаковки.МаксимальнаяУпаковкаВВетви,
	|	ВариантыПереупаковки.Количество
	|ИЗ
	|	РегистрСведений.ВариантыПереупаковки КАК ВариантыПереупаковки
	|ГДЕ
	|	ВариантыПереупаковки.Упаковка = &Упаковка
	|	И ВариантыПереупаковки.Источник.ПометкаУдаления = ЛОЖЬ";
	
	Запрос.УстановитьПараметр("Упаковка",РодительСсылка);
	
	Возврат Не Запрос.Выполнить().Пустой();
	
КонецФункции

Процедура ОбновитьВариантыПереупаковки()
	
	ТаблицаВариантовПереупаковки = Справочники.УпаковкиЕдиницыИзмерения.СформироватьТаблицуВариантовПереупаковкиНаСервере(Владелец);
	
	ДополнитьТаблицуВариантовПереупаковки(ТаблицаВариантовПереупаковки);
	
	ТЗМаксимальныеУпаковкиВВетви = ТаблицаВариантовПереупаковки.Скопировать(,"МаксимальнаяУпаковкаВВетви");
	ТЗМаксимальныеУпаковкиВВетви.Свернуть("МаксимальнаяУпаковкаВВетви");
	МаксимальныеУпаковкиВВетви = ТЗМаксимальныеУпаковкиВВетви.ВыгрузитьКолонку("МаксимальнаяУпаковкаВВетви");
	
	Для Каждого МаксимальнаяУпаковкаВВетви Из МаксимальныеУпаковкиВВетви Цикл
		
		Отбор = Новый Структура("МаксимальнаяУпаковкаВВетви", МаксимальнаяУпаковкаВВетви);
		ВариантыПереупаковки = ТаблицаВариантовПереупаковки.Скопировать(Отбор);
		
		Набор = РегистрыСведений.ВариантыПереупаковки.СоздатьНаборЗаписей();
		Набор.Отбор.МаксимальнаяУпаковкаВВетви.Установить(МаксимальнаяУпаковкаВВетви);
		Набор.Загрузить(ВариантыПереупаковки);
		Набор.Записать();
		
	КонецЦикла;
	
	// Очистить записи в регистре по максимальным упаковкам в ветви более неиспользуемым.
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВариантыПереупаковки.МаксимальнаяУпаковкаВВетви КАК МаксимальнаяУпаковкаВВетви
	|ИЗ
	|	РегистрСведений.ВариантыПереупаковки КАК ВариантыПереупаковки
	|ГДЕ
	|	НЕ ВариантыПереупаковки.МаксимальнаяУпаковкаВВетви В (&МаксимальнаяУпаковкаВВетви)
	|	И ВариантыПереупаковки.МаксимальнаяУпаковкаВВетви.Владелец = &Владелец";
	Запрос.УстановитьПараметр("МаксимальнаяУпаковкаВВетви", МаксимальныеУпаковкиВВетви);
	Запрос.УстановитьПараметр("Владелец", Владелец);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Набор = РегистрыСведений.ВариантыПереупаковки.СоздатьНаборЗаписей();
		Набор.Отбор.МаксимальнаяУпаковкаВВетви.Установить(Выборка.МаксимальнаяУпаковкаВВетви);
		Набор.Очистить();
		Набор.Записать();
	КонецЦикла;
	
КонецПроцедуры

// Проверяет корректность ввода числовых реквизитов. Защищает от ошибки SQL: Переполнение поля.
//
// Параметры:
//  Отказ	 - Булево	 - устанавливается значение Истина, если проверка не пройдена.
//
Процедура ПроверитьКратностьЧисловыхРеквизитов(Отказ)
	
	СообщениеКратностьБолее = НСтр("ru = 'Кратность более 10 000 000 / 1';
									|en = 'Ratio exceeds 10,000,000:1'");
	СообщениеКратностьМенее = НСтр("ru = 'Кратность менее 1 / 99 999 999';
									|en = 'Ratio is less than 1:99,999,999'");
	Если ЗначениеЗаполнено(Знаменатель) Тогда
		Если Числитель / Знаменатель < 0.0000001 Тогда
			
			ОбщегоНазначения.СообщитьПользователю(
				СообщениеКратностьБолее,
				,
				"Объект.Знаменатель",
				,
				Отказ);
			
		ИначеЕсли Числитель / Знаменатель > 99999999 Тогда
			
			ОбщегоНазначения.СообщитьПользователю(
				СообщениеКратностьМенее,
				,
				"Объект.Числитель",
				,
				Отказ);
			
		КонецЕсли;
	КонецЕсли;
	
	Если ТипИзмеряемойВеличины = Перечисления.ТипыИзмеряемыхВеличин.Упаковка
		И ТипУпаковки = Перечисления.ТипыУпаковокНоменклатуры.ТоварноеМесто
		И ЗначениеЗаполнено(КоличествоУпаковок) И КоличествоУпаковок / 1 > 99999999 Тогда
		
		ОбщегоНазначения.СообщитьПользователю(
			СообщениеКратностьМенее,
			,
			"Объект.КоличествоУпаковок",
			,
			Отказ);
		
	КонецЕсли;
	
	СообщениеКратностьБолее = НСтр("ru = 'Кратность к %ПредставлениеБазовойЕдиницыИзмерения% более 99 999 999 / 1';
									|en = 'Ratio is less than 1:99,999,999. Unit: %ПредставлениеБазовойЕдиницыИзмерения%'");
	СообщениеКратностьМенее = НСтр("ru = 'Кратность к %ПредставлениеБазовойЕдиницыИзмерения% менее 1 / 10 000 000';
									|en = 'Ratio exceeds 10,000,000:1. Unit: %ПредставлениеБазовойЕдиницыИзмерения%'");
	Если ТипИзмеряемойВеличины = Перечисления.ТипыИзмеряемыхВеличин.Упаковка Тогда
		
		Если ЗначениеЗаполнено(Объем) И ЗначениеЗаполнено(ОбъемЕдиницаИзмерения) Тогда
			ПредставлениеБазовойЕдиницыИзмерения = НСтр("ru = 'м3';
														|en = 'm3'");
			РеквизитыОбъемЕдиницаИзмерения = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ОбъемЕдиницаИзмерения, "Числитель, Знаменатель");
			Если Объем * (РеквизитыОбъемЕдиницаИзмерения.Числитель / РеквизитыОбъемЕдиницаИзмерения.Знаменатель) < 0.0000001 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьМенее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Объем",
					,
					Отказ);
				
			ИначеЕсли Объем * (РеквизитыОбъемЕдиницаИзмерения.Числитель / РеквизитыОбъемЕдиницаИзмерения.Знаменатель) > 99999999 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьБолее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Объем",
					,
					Отказ);
				
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Вес) И ЗначениеЗаполнено(ВесЕдиницаИзмерения) Тогда
			ПредставлениеБазовойЕдиницыИзмерения = НСтр("ru = 'кг';
														|en = 'kg'");
			РеквизитыВесЕдиницаИзмерения = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ВесЕдиницаИзмерения, "Числитель, Знаменатель");
			Если Вес * (РеквизитыВесЕдиницаИзмерения.Числитель / РеквизитыВесЕдиницаИзмерения.Знаменатель) < 0.0000001 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьМенее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Вес",
					,
					Отказ);
				
			ИначеЕсли Вес * (РеквизитыВесЕдиницаИзмерения.Числитель / РеквизитыВесЕдиницаИзмерения.Знаменатель) > 99999999 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьБолее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Вес",
					,
					Отказ);
				
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Глубина) И ЗначениеЗаполнено(ГлубинаЕдиницаИзмерения) Тогда
			ПредставлениеБазовойЕдиницыИзмерения = НСтр("ru = 'м';
														|en = 'm'");
			РеквизитыГлубинаЕдиницаИзмерения = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ГлубинаЕдиницаИзмерения, "Числитель, Знаменатель");
			Если Глубина * (РеквизитыГлубинаЕдиницаИзмерения.Числитель / РеквизитыГлубинаЕдиницаИзмерения.Знаменатель) < 0.0000001 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьМенее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Глубина",
					,
					Отказ);
				
			ИначеЕсли Глубина * (РеквизитыГлубинаЕдиницаИзмерения.Числитель / РеквизитыГлубинаЕдиницаИзмерения.Знаменатель) > 99999999 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьБолее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Глубина",
					,
					Отказ);
				
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Ширина) И ЗначениеЗаполнено(ШиринаЕдиницаИзмерения) Тогда
			ПредставлениеБазовойЕдиницыИзмерения = НСтр("ru = 'м';
														|en = 'm'");
			РеквизитыШиринаЕдиницаИзмерения = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ШиринаЕдиницаИзмерения, "Числитель, Знаменатель");
			Если Ширина * (РеквизитыШиринаЕдиницаИзмерения.Числитель / РеквизитыШиринаЕдиницаИзмерения.Знаменатель) < 0.0000001 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьМенее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Ширина",
					,
					Отказ);
				
			ИначеЕсли Ширина * (РеквизитыШиринаЕдиницаИзмерения.Числитель / РеквизитыШиринаЕдиницаИзмерения.Знаменатель) > 99999999 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьБолее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Ширина",
					,
					Отказ);
				
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Высота) И ЗначениеЗаполнено(ВысотаЕдиницаИзмерения) Тогда
			ПредставлениеБазовойЕдиницыИзмерения = НСтр("ru = 'м';
														|en = 'm'");
			РеквизитыВысотаЕдиницаИзмерения = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ВысотаЕдиницаИзмерения, "Числитель, Знаменатель");
			Если Высота * (РеквизитыВысотаЕдиницаИзмерения.Числитель / РеквизитыВысотаЕдиницаИзмерения.Знаменатель) < 0.0000001 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьМенее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Высота",
					,
					Отказ);
				
			ИначеЕсли Высота * (РеквизитыВысотаЕдиницаИзмерения.Числитель / РеквизитыВысотаЕдиницаИзмерения.Знаменатель) > 99999999 Тогда
				
				ОбщегоНазначения.СообщитьПользователю(
					СтрЗаменить(СообщениеКратностьБолее, "%ПредставлениеБазовойЕдиницыИзмерения%", ПредставлениеБазовойЕдиницыИзмерения),
					,
					"Объект.Высота",
					,
					Отказ);
				
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;

	Отказ = Ложь;
	
КонецПроцедуры

// Дополняет таблицу возможных вариантов переупаковки новыми связями:
// упаковки из разных веток с одинаковым родителем и кратными коэффициентами связываются друг с другом.
//
// Параметры:
//  ТаблицаВариантовПереупаковки - ТаблицаЗначений - таблица первоначально сгенерированных вариантов переупаковки.
//
Процедура ДополнитьТаблицуВариантовПереупаковки(ТаблицаВариантовПереупаковки)
	
	ТаблицаДополнительныхСвязей = ТаблицаВариантовПереупаковки.СкопироватьКолонки();
	
	Для Каждого СтрокаБольшаяУпаковка Из ТаблицаВариантовПереупаковки Цикл
		
		СтруктураПоиска = Новый Структура("Упаковка");
		СтруктураПоиска.Упаковка = СтрокаБольшаяУпаковка.Упаковка;
		
		ПоискСтрок = ТаблицаВариантовПереупаковки.НайтиСтроки(СтруктураПоиска);
		Для Каждого СтрокаМеньшаяУпаковка Из ПоискСтрок Цикл
			
			Если СтрокаБольшаяУпаковка.Источник <> СтрокаМеньшаяУпаковка.Источник
				И СтрокаМеньшаяУпаковка.Количество <> 0
				И СтрокаБольшаяУпаковка.Количество > СтрокаМеньшаяУпаковка.Количество
				И СтрокаБольшаяУпаковка.Количество % СтрокаМеньшаяУпаковка.Количество = 0 Тогда
				
				НоваяСтрока = ТаблицаДополнительныхСвязей.Добавить();
				НоваяСтрока.Источник = СтрокаБольшаяУпаковка.Источник;
				НоваяСтрока.Упаковка = СтрокаМеньшаяУпаковка.Источник;
				НоваяСтрока.МаксимальнаяУпаковкаВВетви = СтрокаБольшаяУпаковка.МаксимальнаяУпаковкаВВетви;
				НоваяСтрока.Количество = СтрокаБольшаяУпаковка.Количество / СтрокаМеньшаяУпаковка.Количество;
				
			КонецЕсли;
			
		КонецЦикла;
		
	КонецЦикла;
	
	Для Каждого СтрокаДополнительнаяСвязь Из ТаблицаДополнительныхСвязей Цикл
		
		СтруктураПоиска = Новый Структура("Источник, Упаковка, МаксимальнаяУпаковкаВВетви");
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, СтрокаДополнительнаяСвязь);
		
		ПоискСтрок = ТаблицаВариантовПереупаковки.НайтиСтроки(СтруктураПоиска);
		Если ПоискСтрок.Количество() = 0 Тогда		
			НоваяСтрока = ТаблицаВариантовПереупаковки.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаДополнительнаяСвязь);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
#КонецЕсли

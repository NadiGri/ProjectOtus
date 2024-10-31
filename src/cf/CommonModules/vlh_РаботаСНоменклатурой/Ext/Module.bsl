﻿
#Область РаботаСНСИ
//Процедура загружает данные для далнейшего заполения настроек
Процедура ЗагрузкаНастроекДляСозданияНоменклатур() Экспорт
	
	ЗагрузкаНоменклатурныхГруппАх();
    ЗагрузкаДанныхДляНастройкиСозданияНоменклатур(); 
	ЗагрузкаЕдиницИзмеренияАх();
	
КонецПроцедуры  

//в данную процедуру мы передаем информацию о кодах аксапты,
//на основании которых или находим созданную и зарегестрированную ранее
//или отправляем запрос в аксапату для создания новой номенклатуры
Функция ПолучитьНоменклатуруХарактеристику(Артикул, Цвет, Остекление, Конфигурация, Размер) Экспорт  
	
	//сначала попробудем поискать, даже если не найдем, то получим в ответ пустую структуру
	Результат = НайтиНоменклатуруХарактеристику(Артикул, Цвет, Остекление, Конфигурация, Размер);
	
	Если  Результат.Номенклатура = Справочники.Номенклатура.ПустаяСсылка() ТОгда
		
		ДанныеАХ = ПолучениеДанныхДляСозданияНСИ(Артикул, Цвет, Остекление, Конфигурация, Размер);
		Если ДанныеАХ.Ошибка тогда
			 //тут зарегистрируем ошибку
			 РегистрацияОшибокПриСозданииНоменклатур(ДанныеАХ);
			 
		 Иначе  
			 //Сначала попробуем найти номенклатуру по артикулу
			 ДанныеАХ.Номенклатура = Справочники.Номенклатура.НайтиПоРеквизиту("Артикул",СокрЛП(ДанныеАХ.ITEMID));
			 Если ДанныеАХ.Номенклатура = Справочники.Номенклатура.ПустаяСсылка() Тогда
			 
			 	//дополним данные параметрами необходимыми для создания номенклатур/характеристик  
				//найдем ед. измерения
			     НайтиЕдиницуИзмерения(ДанныеАХ); 
				 
				 //найдем родителя и вид Номенклатуры 
				 НайтиРодителяИВидНоменклатуры(ДанныеАХ);
				 //если нет ошибок попробуем создать номенклатуру
				 Если не ДанныеАХ.Ошибка Тогда
					 
					 
					  СоздатьНоменклатуру(ДанныеАХ);
					 
					 
				 КонецЕсли;
			 иначе
				 
				 //заполним данные из найденной номенклатуры, вдруг потом будет ошибка чтобы все поместить в регистр ошибок 
				ДанныеАХ.Родитель =  ДанныеАХ.Номенклатура.Родитель;
				ДанныеАХ.ВидНоменклатуры = ДанныеАХ.Номенклатура.ВидНоменклатуры;
				ДанныеАХ.ЕдиницаИзмерения = ДанныеАХ.Номенклатура.ЕдиницаИзмерения;
			 
			КонецЕсли; 
			
			//попрубуем создать характеристику
			Если не ДанныеАХ.Ошибка Тогда
				Если ДанныеАХ.ВидНоменклатуры.ИспользоватьХарактеристики ТОгда  
					
					//тут работаем с характристиками
					//НайтиСоздатьДополнительноеСвойство(Свойство, Значение, Описание);
					Если СокрЛП(ДанныеАХ.CONFIGID)<>"" Тогда
						ДанныеАХ.Конфигурация =  НайтиСоздатьДополнительноеСвойство(Справочники.VLH_ПредопределенныеСсылки.Конфигурация.Значение, ДанныеАХ.CONFIGID, ДанныеАХ.CONFIGIDName);
						Если ДанныеАХ.Конфигурация = Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка() ТОгда
							ДанныеАХ.Ошибка = Истина;
							ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " Конфигурация не создана. ";
						КонецЕсли;                           
					КонецЕсли;
					Если СокрЛП(ДанныеАХ.INVENTCOLORID)<>"" Тогда
						ДанныеАХ.Цвет =  НайтиСоздатьДополнительноеСвойство(Справочники.VLH_ПредопределенныеСсылки.Цвет.Значение, ДанныеАХ.INVENTCOLORID, ДанныеАХ.INVENTCOLORIDName);
						Если ДанныеАХ.Цвет = Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка() ТОгда
							ДанныеАХ.Ошибка = Истина;
							ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " Цвет не создан. ";
						КонецЕсли;  
					КонецЕсли; 
					Если СокрЛП(ДанныеАХ.INVENTSIZEID)<>"" Тогда
						ДанныеАХ.Размер =  НайтиСоздатьДополнительноеСвойство(Справочники.VLH_ПредопределенныеСсылки.Размер.Значение, ДанныеАХ.INVENTSIZEID, ДанныеАХ.INVENTSIZEIDName);
						Если ДанныеАХ.Размер = Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка() ТОгда
							ДанныеАХ.Ошибка = Истина;
							ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " Размер не создан. ";
						КонецЕсли;   
					КонецЕсли; 
					Если СокрЛП(ДанныеАХ.VLH_INVENTGLAZINGID)<>"" Тогда
						ДанныеАХ.Остекление =  НайтиСоздатьДополнительноеСвойство(Справочники.VLH_ПредопределенныеСсылки.Остекление.Значение, ДанныеАХ.VLH_INVENTGLAZINGID, ДанныеАХ.VLH_INVENTGLAZINGIDName);
						Если ДанныеАХ.Остекление = Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка() ТОгда
							ДанныеАХ.Ошибка = Истина;
							ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " Остекление не создано. ";
						КонецЕсли;
					КонецЕсли; 
					//создаем
					Если не ДанныеАХ.Ошибка Тогда
						
						 НайтиСоздатьХарактеристику(ДанныеАХ);
					
					КонецЕсли;
				КонецЕсли; 
			КонецЕсли;
			 
		КонецЕсли;
		
		Если ДанныеАХ.Ошибка тогда
			//тут зарегистрируем ошибку
			РегистрацияОшибокПриСозданииНоменклатур(ДанныеАХ); 
		иначе 
			//зарегестрируем соответсвие
			РегистрацияСоответствийНоменклатурDAX_1с(ДанныеАХ);
			
			//присвоем ответ и вернем его
			Результат.Номенклатура = ДанныеАХ.Номенклатура;
			Результат.ХарактеристикаНоменклатуры = ДанныеАХ.ХарактеристикаНоменклатуры; 
			Результат.ИспользоватьХарактеристики = ДанныеАХ.ВидНоменклатуры.ИспользоватьХарактеристики;
		КонецЕсли;
	
	КонецЕсли;	
	Возврат  Результат;
	
КонецФункции 
  
#КонецОбласти

#Область ПолучениеДанныхИзАксапты
//Процедура для заполнения и обновления справочника НоменклатурныеГруппыАХ
Процедура ЗагрузкаНоменклатурныхГруппАх()
	
	СтрокаСоединения = vlh_РаботаСБазойДанных.СформироватьСтрокуПодключения("AX-SQL", "DAX5_WORK");
	СоединениеТекущее = vlh_РаботаСБазойДанных.СоединениеНачальнаяИнициализация();
	КомандаСКЛ = "SELECT [ITEMGROUPID] as Код
				  |  ,[NAME] as Имя
				  |FROM [DAX5_WORK].[dbo].[INVENTITEMGROUP]
				  |where DATAAREAID = 'vrt'";
	vlh_РаботаСБазойДанных.СоединениеОткрыть(СоединениеТекущее, СтрокаСоединения);
	ТаблоСод = vlh_РаботаСБазойДанных.ЗапросыПолучитьТаблицу(СоединениеТекущее,КомандаСКЛ);
	vlh_РаботаСБазойДанных.СоединениеЗакрыть(СоединениеТекущее);
	ТаблоСод.Свернуть("КОД,Имя");
	
	Для Каждого Стр Из ТаблоСод Цикл
		нСтр = Справочники.vlh_НоменклатурныеГруппыАХ.НайтиПоКоду(стр.Код);
		если нстр = Справочники.vlh_НоменклатурныеГруппыАХ.ПустаяСсылка() ТОгда
			нСтр = Справочники.vlh_НоменклатурныеГруппыАХ.СоздатьЭлемент();
			нСтр.Код = Стр.КОД;
			нСтр.Наименование = Стр.Имя;
		Иначе
			нстр = нСтр.ПолучитьОбъект();
			нСтр.Наименование = Стр.Имя;
		КонецЕсли;
		нСтр.Записать();
	КонецЦиклА;	
	
КонецПроцедуры 

//Процедура для заполнения регистра сведений настроек создания номенклатур
Процедура ЗагрузкаДанныхДляНастройкиСозданияНоменклатур()
	
	СтрокаСоединения = vlh_РаботаСБазойДанных.СформироватьСтрокуПодключения("AX-SQL", "DAX5_WORK");
	СоединениеТекущее = vlh_РаботаСБазойДанных.СоединениеНачальнаяИнициализация();
	vlh_РаботаСБазойДанных.СоединениеОткрыть(СоединениеТекущее, СтрокаСоединения);
	СписокПараметров =  vlh_РаботаСБазойДанных.ПолучитьТаблицуПараметровДляХранимыхПроцедур();
	ТаблоСодержанияНастроек = vlh_РаботаСБазойДанных.ВыполнитьХранимуюПроцедуруВозвращающуюТабличноеЗначение(СоединениеТекущее, "_VLH_1C_ERP_BUH_Get_PRODUCTTYPEID", СписокПараметров); 
	vlh_РаботаСБазойДанных.СоединениеЗакрыть(СоединениеТекущее);
	Для каждого стр Из ТаблоСодержанияНастроек Цикл
		
		НомГруппаАХ =  Справочники.vlh_НоменклатурныеГруппыАХ.НайтиПоКоду(стр.НоменклатурнаяГруппаАХ);

		НЗап = РегистрыСведений.vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ.СоздатьНаборЗаписей();
		НЗап.Отбор.ГруппаНоменклатуры.Значение = стр.ГруппаНоменклатуры;
		НЗап.Отбор.ВидПродукции.Значение = стр.ВидПродукции;
		НЗап.Отбор.НоменклатурнаяГруппаАХ.Значение = НомГруппаАХ;		
		НЗап.Отбор.ТоварнаяГруппа.Значение = стр.ТоварнаяГруппа;
		НЗап.Отбор.ГруппаНоменклатуры.Использование = Истина;
		НЗап.Отбор.ВидПродукции.Использование = Истина;
		НЗап.Отбор.НоменклатурнаяГруппаАХ.Использование = Истина;
		НЗап.Отбор.ТоварнаяГруппа.Использование = Истина;
		
		НЗап.Прочитать();
		Если НЗап.Количество() = 0 Тогда
			Зрег = НЗап.Добавить();
			Зрег.Активность = истина;  
			Зрег.ГруппаНоменклатуры = стр.ГруппаНоменклатуры;
			Зрег.ВидПродукции = стр.ВидПродукции;
			Зрег.НоменклатурнаяГруппаАХ = НомГруппаАХ;
			Зрег.ТоварнаяГруппа = стр.ТоварнаяГруппа;
			
			НЗап.Записать();             
		КонецЕсли;
		
	КонецЦикла;
	
	
	
	
КонецПроцедуры   

//Процедура для заполнения и обновления регистра сопоставления ед. измерения
Процедура ЗагрузкаЕдиницИзмеренияАх()
	
	СтрокаСоединения = vlh_РаботаСБазойДанных.СформироватьСтрокуПодключения("AX-SQL", "DAX5_WORK");
	СоединениеТекущее = vlh_РаботаСБазойДанных.СоединениеНачальнаяИнициализация();
	КомандаСКЛ = "SELECT [UNITID] as ЕдиницаИзмеренияАХ
				|FROM [DAX5_WORK].[dbo].[INVENTTABLEMODULE]
				|where DATAAREAID = 'vrt' and MODULETYPE=0 and [UNITID]<>''
				|group by [UNITID]
				|order by [UNITID]";
	vlh_РаботаСБазойДанных.СоединениеОткрыть(СоединениеТекущее, СтрокаСоединения);
	ТаблоСод = vlh_РаботаСБазойДанных.ЗапросыПолучитьТаблицу(СоединениеТекущее,КомандаСКЛ);
	vlh_РаботаСБазойДанных.СоединениеЗакрыть(СоединениеТекущее);
	
	Для Каждого Стр Из ТаблоСод Цикл
		НЗап = РегистрыСведений.vlh_СопоставлениеЕдиницИзмеренияСАХ.СоздатьНаборЗаписей();
		НЗап.Отбор.ЕдиницаИзмеренияАХ.Значение = стр.ЕдиницаИзмеренияАХ;
		НЗап.Отбор.ЕдиницаИзмеренияАХ.Использование = Истина;
		
		НЗап.Прочитать();
		Если НЗап.Количество() = 0 Тогда
			Зрег = НЗап.Добавить();
			Зрег.Активность = истина;  
			Зрег.ЕдиницаИзмеренияАХ = стр.ЕдиницаИзмеренияАХ;
			НЗап.Записать();             
		КонецЕсли;

		
		
	КонецЦиклА;	
	
КонецПроцедуры 


Функция ПолучениеДанныхДляСозданияНСИ(Артикул, Цвет, Остекление, Конфигурация, Размер) 
	
		ДанныеАХ = ПолучитьСтруктуруДанныхНСИАХ(); 
		ДанныеАХ.AxId =  Артикул+"_"+Цвет+"_"+Остекление+"_"+Конфигурация+"_"+Размер;	
		ДанныеАХ.ITEMID = Артикул;	
		ДанныеАХ.CONFIGID = Конфигурация;	
		ДанныеАХ.INVENTCOLORID = Цвет;	
		ДанныеАХ.INVENTSIZEID = Размер;	
		ДанныеАХ.VLH_INVENTGLAZINGID = Остекление;	

	
	 	//тут получим данные из аксапты
		СтрокаСоединения = vlh_РаботаСБазойДанных.СформироватьСтрокуПодключения("AX-SQL", "DAX5_WORK");
		СоединениеТекущее = vlh_РаботаСБазойДанных.СоединениеНачальнаяИнициализация();
		vlh_РаботаСБазойДанных.СоединениеОткрыть(СоединениеТекущее, СтрокаСоединения);
		СписокПараметров =  vlh_РаботаСБазойДанных.ПолучитьТаблицуПараметровДляХранимыхПроцедур();
		сп = СписокПараметров.Добавить();		
		сп.Имя = "@ITEMID";
		сп.Значение = Артикул;
		
		сп = СписокПараметров.Добавить();		
		сп.Имя = "@CONFIGID";   
		сп.Значение = Конфигурация;  
		
		сп = СписокПараметров.Добавить();		
		сп.Имя = "@INVENTCOLORID";   
		сп.Значение = Цвет;  
		
		сп = СписокПараметров.Добавить();		
		сп.Имя = "@VLH_INVENTGLAZINGID";   
		сп.Значение = Остекление;  
		
		сп = СписокПараметров.Добавить();		
		сп.Имя = "@INVENTSIZEID";   
		сп.Значение = Размер;  
		Попытка
			ТаблоСодержания = vlh_РаботаСБазойДанных.ВыполнитьХранимуюПроцедуруВозвращающуюТабличноеЗначение(СоединениеТекущее, "_VLH_1C_ERP_BUH_AX_ItemData", СписокПараметров); 
		Исключение
			 ДанныеАХ.Ошибка = Истина; 
			 ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " При обращении к AX-SQL/DAX5_WORK произошла ошибка";
		КонецПопытки;
		
		
		vlh_РаботаСБазойДанных.СоединениеЗакрыть(СоединениеТекущее); 
		Если ТаблоСодержания.Количество()=0 Тогда
			 ДанныеАХ.Ошибка = Истина;
			 ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " Аксапта не вернула данные по введенным кодам, проверьте их. ";
		Иначе
			ЗаполнитьЗначенияСвойств(ДанныеАХ,ТаблоСодержания[0],,"НоменклатурнаяГруппаАХ"); 
			ДанныеАХ.НоменклатурнаяГруппаАХ = Справочники.vlh_НоменклатурныеГруппыАХ.НайтиПоКоду(ТаблоСодержания[0].НоменклатурнаяГруппаАХ); 
			
		КонецЕсли;
		
		Возврат ДанныеАХ;
		
КонецФункции

#КонецОбласти


#Область СозданияНСИ

Функция НайтиСоздатьДополнительноеСвойство(Свойство, Значение, Описание)    
	
	ЗначениеПоиска = Справочники.ЗначенияСвойствОбъектов.НайтиПоНаименованию(Значение, Истина,,Свойство);  
	Если ЗначениеПоиска = Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка() ТОгда
		НовЭл = Справочники.ЗначенияСвойствОбъектов.СоздатьЭлемент();
		НовЭл.Владелец = Свойство;
		НовЭл.Наименование = Значение;
		НовЭл.ПолноеНаименование = Описание;
		Попытка
			НовЭл.Записать();
			ЗначениеПоиска = НовЭл.Ссылка;
		Исключение		
			ЗначениеПоиска = Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка();
		КонецПопытки;
	КонецЕсли;
	
	Возврат ЗначениеПоиска;
	
КонецФункции

ПРоцедура СоздатьНоменклатуру(ДанныеАХ)
	
	Ном = Справочники.Номенклатура.СоздатьЭлемент();
	Ном.ВидНоменклатуры = ДанныеАХ.ВидНоменклатуры;
	ном.Родитель = ДанныеАХ.Родитель;
	Справочники.Номенклатура.ЗаполнитьРеквизитыПоВидуНоменклатуры(Ном); 
	Ном.Артикул = ДанныеАХ.ITEMID;
	ном.Наименование = ДанныеАХ.ITEMIDName; 
	ном.НаименованиеПолное = ДанныеАХ.ITEMIDNameFull;
	ном.ЕдиницаИзмерения = ДанныеАХ.ЕдиницаИзмерения;
	ном.ЕдиницаДляОтчетов = ном.ЕдиницаИзмерения;
	ном.КоэффициентЕдиницыДляОтчетов = 1;
	ном.Качество = Перечисления.ГрадацииКачества.Новый;
	
	Попытка
		ном.Записать();  
		ДанныеАХ.Номенклатура = ном.Ссылка;
	Исключение     
		ИнформацияОбОшибке = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());  
		ДанныеАХ.Ошибка = Истина;
		ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + ИнформацияОбОшибке;
		
	КонецПопытки;
	
	


	
КонецПроцедуры

Процедура НайтиСоздатьХарактеристику(ДанныеАХ)
	
	//Сначала проверим может уже создана, но не зарегистирована
	
	ДанныеХарактеристики = Новый Соответствие;  
	ДанныеХарактеристики.Вставить(Справочники.VLH_ПредопределенныеСсылки.Конфигурация.Значение, ДанныеАХ.Конфигурация);  
	ДанныеХарактеристики.Вставить(Справочники.VLH_ПредопределенныеСсылки.Цвет.Значение, ДанныеАХ.Цвет); 
	ДанныеХарактеристики.Вставить(Справочники.VLH_ПредопределенныеСсылки.Размер.Значение, ДанныеАХ.Размер); 
	ДанныеХарактеристики.Вставить(Справочники.VLH_ПредопределенныеСсылки.Остекление.Значение, ДанныеАХ.Остекление);
	НетДанных = Истина;
	Для каждого СтрокаДанных из ДанныеХарактеристики ЦИкл
		Если ЗначениеЗаполнено(СтрокаДанных.Значение) ТОгда
			 НетДанных = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Если НетДанных Тогда
		ДанныеАХ.Ошибка = Истина;
		ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " Нет заполненных доп. реквизитов для создания характеристики. ";
	КонецЕсли;
	
	Если не ДанныеАХ.Ошибка Тогда 
		
		запрос = Новый Запрос;
		ТекстПолей =  "ВЫБРАТЬ
		|	ХарактеристикиНоменклатуры.Ссылка КАК Ссылка ";
		ТекстСоединения = " 
		|ИЗ
		|	Справочник.ХарактеристикиНоменклатуры КАК ХарактеристикиНоменклатуры  ";
		
		счетчикСвойств = 1;
		ФлагИ = Ложь;
		СтуктураОтбораПоСвойствамАХ  = Новый Структура;
		Для каждого СтрокаДанных из ДанныеХарактеристики ЦИкл
			СтрСчСВ = Строка(счетчикСвойств);
			ТекстПолей = ТекстПолей + ","
			+ "ЕСТЬNULL(Свойство"+СтрСчСВ+".Значение, ""НЕЗАПОЛНЕНО"") КАК Поле"+ СтрСчСВ;
			
			ТекстСоединения = ТекстСоединения+ 
			"
			|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
			|			ХарактеристикиНоменклатурыДополнительныеРеквизиты.Ссылка КАК Ссылка,
			|			ХарактеристикиНоменклатурыДополнительныеРеквизиты.Значение КАК Значение
			|		ИЗ
			|			Справочник.ХарактеристикиНоменклатуры.ДополнительныеРеквизиты КАК ХарактеристикиНоменклатурыДополнительныеРеквизиты
			|		ГДЕ
			|			ХарактеристикиНоменклатурыДополнительныеРеквизиты.Ссылка.Владелец = &Владелец
			|			И ХарактеристикиНоменклатурыДополнительныеРеквизиты.Свойство = &Свойство"+СтрСчСВ+"
			|			И НЕ ХарактеристикиНоменклатурыДополнительныеРеквизиты.Ссылка.ПометкаУдаления) КАК Свойство"+СтрСчСВ+"
			|		ПО ХарактеристикиНоменклатуры.Ссылка = Свойство"+СтрСчСВ+".Ссылка";
			
			флагИ = Истина;
			Запрос.УстановитьПараметр("Свойство"+СтрСчСВ, СтрокаДанных.Ключ);
			Если ЗначениеЗаполнено(СтрокаДанных.Значение) ТОгда
				СтуктураОтбораПоСвойствамАХ.Вставить("Поле"+СтрСчСВ, СтрокаДанных.Значение); 
			Иначе
				СтуктураОтбораПоСвойствамАХ.Вставить("Поле"+СтрСчСВ, "НЕЗАПОЛНЕНО");
			КонецЕсли;	
			
			счетчикСвойств = счетчикСвойств+1;			
		КонецЦикла;
		ТекстЗапроса = ТекстПолей + ТекстСоединения +"
		|ГДЕ
		|	ХарактеристикиНоменклатуры.Владелец = &Владелец
		|	И НЕ ХарактеристикиНоменклатуры.ПометкаУдаления" ;
		
		Запрос.Текст =  ТекстЗапроса;
		Запрос.УстановитьПараметр("Владелец", ДанныеАХ.Номенклатура);
		РезЗапроса = Запрос.Выполнить();
		флСоздания = Ложь;
		Если РезЗапроса.Пустой() тогда
			флСоздания = Истина;	
		Иначе	
			СтрочкиПоУсловиям = РезЗапроса.Выгрузить().НайтиСтроки(СтуктураОтбораПоСвойствамАХ);
			Если СтрочкиПоУсловиям.Количество() = 0 ТОгда
				флСоздания = Истина;
			Иначе
				ДанныеАХ.ХарактеристикаНоменклатуры = СтрочкиПоУсловиям[0].Ссылка;
			КонецЕсли;
		КонецЕсли;   
		
		Если флСоздания Тогда
			
			
			СпрХарактеристики = Справочники.ХарактеристикиНоменклатуры;
			Отказ = Ложь;
			НоваяХарактеристика = СпрХарактеристики.СоздатьЭлемент();
			НоваяХарактеристика.Владелец = ДанныеАХ.Номенклатура;
			НоваяХарактеристика.ВидНоменклатуры =  ДанныеАХ.ВидНоменклатуры;
			СтрокаНаименования = "";
			Для каждого СтрокаСвойства из ДанныеХарактеристики Цикл 
				Если ЗначениеЗаполнено(СтрокаСвойства.Значение) ТОгда
					
					НовСвойство = НоваяХарактеристика.ДополнительныеРеквизиты.Добавить();
					НовСвойство.Свойство = СтрокаСвойства.Ключ;
					НовСвойство.Значение = СтрокаСвойства.Значение; 
				КонецЕсли;
			КонецЦикла;
			Наименование = СокрЛП(СтрЗаменить(ДанныеАХ.ITEMIDNameFull,ДанныеАХ.ITEMIDName+",",""));
			НоваяХарактеристика.Наименование = Наименование;
			НоваяХарактеристика.НаименованиеПолное = Наименование;
			
			Попытка
				НоваяХарактеристика.Записать();
				ДанныеАХ.ХарактеристикаНоменклатуры  = НоваяХарактеристика.Ссылка;
			Исключение
				ИнформацияОбОшибке = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());  
				ДанныеАХ.Ошибка = Истина;
				ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + ИнформацияОбОшибке;
			КонецПопытки;
			
		КонецЕсли;	
	КонецЕсли;
	
КонецПроцедуры


#КонецОбласти      



#Область ПоискИРегистрацияСоответствийНСИ  

//процедура по кодам аксапты ищет сопоствленную ранее номенклатуру
Функция НайтиНоменклатуруХарактеристику(Артикул, Цвет, Остекление, Конфигурация, Размер) экспорт

	Результат = Новый Структура("Номенклатура,ХарактеристикаНоменклатуры,ИспользоватьХарактеристики");
	Результат.Номенклатура = Справочники.Номенклатура.ПустаяСсылка();
	Результат.ХарактеристикаНоменклатуры = Справочники.ХарактеристикиНоменклатуры.ПустаяСсылка(); 
	Результат.ИспользоватьХарактеристики = Ложь;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	VLH_СопоставлениеКодовАх1с.Номенклатура КАК Номенклатура,
		|	VLH_СопоставлениеКодовАх1с.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
		|	ВидыНоменклатуры.ИспользоватьХарактеристики КАК ИспользоватьХарактеристики
		|ИЗ
		|	РегистрСведений.VLH_СопоставлениеКодовАх1с КАК VLH_СопоставлениеКодовАх1с
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ВидыНоменклатуры КАК ВидыНоменклатуры
		|		ПО VLH_СопоставлениеКодовАх1с.Номенклатура.ВидНоменклатуры = ВидыНоменклатуры.Ссылка
		|ГДЕ
		|	VLH_СопоставлениеКодовАх1с.AxId = &AxId";
	
	//ищем только по полному коду т.к. может быть номенклатура, но не быть характеристик
	Запрос.УстановитьПараметр("AxId", Артикул+"_"+Цвет+"_"+Остекление+"_"+Конфигурация+"_"+Размер);

	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Результат.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
		Результат.ХарактеристикаНоменклатуры = ВыборкаДетальныеЗаписи.ХарактеристикаНоменклатуры;  
		Результат.ИспользоватьХарактеристики = ВыборкаДетальныеЗаписи.ИспользоватьХарактеристики;  
	КонецЦикла;
	
	Возврат Результат;
 
КонецФункции // ОпределитьНоменклатуруХарактеристику()
  
Процедура НайтиЕдиницуИзмерения(ДанныеАХ) Экспорт 
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	vlh_СопоставлениеЕдиницИзмеренияСАХ.ЕдиницаИзмерения КАК ЕдиницаИзмерения
		|ИЗ
		|	РегистрСведений.vlh_СопоставлениеЕдиницИзмеренияСАХ КАК vlh_СопоставлениеЕдиницИзмеренияСАХ
		|ГДЕ
		|	vlh_СопоставлениеЕдиницИзмеренияСАХ.ЕдиницаИзмеренияАХ = &ЕдиницаИзмеренияАХ";
	
	Запрос.УстановитьПараметр("ЕдиницаИзмеренияАХ", ДанныеАХ.ЕдИзмерения);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() ТОгда     
		Если ВыборкаДетальныеЗаписи.ЕдиницаИзмерения = Справочники.УпаковкиЕдиницыИзмерения.ПустаяСсылка() ТОгда
			ДанныеАХ.Ошибка = Истина;
			ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " В регистре соответствия ед. измерения нет сопоставленной ед. измерения 1с";
		ИНаче
			ДанныеАХ.ЕдиницаИзмерения = ВыборкаДетальныеЗаписи.ЕдиницаИзмерения;
		КонецЕсли;
	ИНаче
		ДанныеАХ.Ошибка = Истина;
		ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " В регистре соответствия ед. измерения нет данных по единице аксапты";
	КонецЕсли;

	
КонецПроцедуры

//поиск группы номенклатуры и вида номенклатуры для дальнейшего создания элемента справочника
Процедура НайтиРодителяИВидНоменклатуры(ДанныеАХ)Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ.Родитель КАК Родитель,
		|	vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ.ВидНоменклатуры КАК ВидНоменклатуры
		|ИЗ
		|	РегистрСведений.vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ КАК vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ
		|ГДЕ
		|	vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ.ГруппаНоменклатуры = &ГруппаНоменклатуры
		|	И vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ.ВидПродукции = &ВидПродукции
		|	И vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ.НоменклатурнаяГруппаАХ = &НоменклатурнаяГруппаАХ
		|	И vlh_НастройкиДляЗагрузкиНоменклатурыВ1сИзАХ.ТоварнаяГруппа = &ТоварнаяГруппа";
	
	Запрос.УстановитьПараметр("ВидПродукции", ДанныеАХ.ВидПродукции);
	Запрос.УстановитьПараметр("ГруппаНоменклатуры", ДанныеАХ.ГруппаНоменклатуры);
	Запрос.УстановитьПараметр("НоменклатурнаяГруппаАХ", ДанныеАХ.НоменклатурнаяГруппаАХ);
	Запрос.УстановитьПараметр("ТоварнаяГруппа", ДанныеАХ.ТоварнаяГруппа);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() ТОгда     
		Если ВыборкаДетальныеЗаписи.Родитель = Справочники.Номенклатура.ПустаяСсылка()
			или  ВыборкаДетальныеЗаписи.ВидНоменклатуры = Справочники.ВидыНоменклатуры.ПустаяСсылка() ТОгда
			ДанныеАХ.Ошибка = Истина;
			ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " В регистре соответствия сопоставленной группы или вида номенклатуры";
		ИНаче
			ДанныеАХ.Родитель = ВыборкаДетальныеЗаписи.Родитель;
			ДанныеАХ.ВидНоменклатуры = ВыборкаДетальныеЗаписи.ВидНоменклатуры;
		КонецЕсли;
	ИНаче
		ДанныеАХ.Ошибка = Истина;
		ДанныеАХ.ТекстОшибки = ДанныеАХ.ТекстОшибки + " В регистре нет подходящего набора данных для определения группы номеклатуры и вида номенклатуры";
	КонецЕсли;
	
КонецПроцедуры


Процедура РегистрацияСоответствийНоменклатурDAX_1с(ДанныеАХ) Экспорт

	AxId = ДанныеАХ.ITEMID + "_" + ДанныеАХ.INVENTCOLORID + "_" + ДанныеАХ.VLH_INVENTGLAZINGID + "_" + ДанныеАХ.CONFIGID + "_" + ДанныеАХ.INVENTSIZEID;
	
	НЗап = РегистрыСведений.VLH_СопоставлениеКодовАх1с.СоздатьНаборЗаписей();
	НЗап.Отбор.AxId.Значение = AxId;
	НЗап.Отбор.AxId.Использование = Истина;
	НЗап.Прочитать();
	НЗап.Очистить();
	Зрег = НЗап.Добавить();
	ЗаполнитьЗначенияСвойств(Зрег,ДанныеАХ);
	Зрег.Активность = истина;
	Зрег.AxId = AxId;
 
	НЗап.Записать();


КонецПроцедуры   



#КонецОбласти

#Область ВспомогательныеПроцедуры

Функция ПолучитьСтруктуруДанныхНСИАХ()
	
    ДанныеАХ =  новый Структура;
	ДанныеАХ.Вставить("AxId","");	
	ДанныеАХ.Вставить("ITEMID","");	
	ДанныеАХ.Вставить("CONFIGID","");	
	ДанныеАХ.Вставить("INVENTCOLORID","");	
	ДанныеАХ.Вставить("INVENTSIZEID","");	
	ДанныеАХ.Вставить("VLH_INVENTGLAZINGID","");	
	ДанныеАХ.Вставить("Модель","");	
	ДанныеАХ.Вставить("Вариант","");	
	ДанныеАХ.Вставить("ИмяНавижн","");	
	ДанныеАХ.Вставить("ПолноеИмяНавижн","");	
	ДанныеАХ.Вставить("ITEMIDName","");	
	ДанныеАХ.Вставить("ITEMIDNameFull","");	
	ДанныеАХ.Вставить("CONFIGIDName","");	
	ДанныеАХ.Вставить("INVENTCOLORIDName","");	
	ДанныеАХ.Вставить("VLH_INVENTGLAZINGIDName","");	
	ДанныеАХ.Вставить("INVENTSIZEIDName","");	
	ДанныеАХ.Вставить("ЕдИзмерения","");	
	ДанныеАХ.Вставить("ГруппаНоменклатуры","");	
	ДанныеАХ.Вставить("ВидПродукции","");	
	ДанныеАХ.Вставить("НоменклатурнаяГруппаАХ",Справочники.vlh_НоменклатурныеГруппыАХ.ПустаяСсылка());	
	ДанныеАХ.Вставить("ТоварнаяГруппа","");	
	ДанныеАХ.Вставить("Конфигурация",Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка());	
	ДанныеАХ.Вставить("Цвет",Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка());	
	ДанныеАХ.Вставить("Остекление",Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка());	
	ДанныеАХ.Вставить("Размер",Справочники.ЗначенияСвойствОбъектов.ПустаяСсылка());	
	ДанныеАХ.Вставить("Родитель",Справочники.Номенклатура.ПустаяСсылка());	
	ДанныеАХ.Вставить("ВидНоменклатуры",Справочники.ВидыНоменклатуры.ПустаяСсылка());	
	ДанныеАХ.Вставить("Номенклатура",Справочники.Номенклатура.ПустаяСсылка());	
	ДанныеАХ.Вставить("ХарактеристикаНоменклатуры",Справочники.ХарактеристикиНоменклатуры.ПустаяСсылка());	
	ДанныеАХ.Вставить("ЕдиницаИзмерения",Справочники.УпаковкиЕдиницыИзмерения.ПустаяСсылка());	
	
	ДанныеАХ.Вставить("Ошибка",Ложь);	
	ДанныеАХ.Вставить("ТекстОшибки","");	
	
	Возврат ДанныеАХ;	
	
КонецФункции

Процедура РегистрацияОшибокПриСозданииНоменклатур(ДанныеАХ)
	
	 	
	нЗап  = РегистрыСведений.VLH_ОшибкиСозданияНоменклатурПриЗагрузкеИзАксапты.СоздатьНаборЗаписей();
	нЗап.Отбор.AxId.Значение = ДанныеАХ.AxId;
	нЗап.Отбор.AxId.Использование = Истина;
	нЗап.Отбор.ITEMID.Значение = ДанныеАХ.ITEMID;
	нЗап.Отбор.ITEMID.Использование = Истина;
	нЗап.Отбор.CONFIGID.Значение = ДанныеАХ.CONFIGID;
	нЗап.Отбор.CONFIGID.Использование = Истина;
	нЗап.Отбор.INVENTCOLORID.Значение = ДанныеАХ.INVENTCOLORID;
	нЗап.Отбор.INVENTCOLORID.Использование = Истина;
	нЗап.Отбор.INVENTSIZEID.Значение = ДанныеАХ.INVENTSIZEID;
	нЗап.Отбор.INVENTSIZEID.Использование = Истина;
	нЗап.Отбор.VLH_INVENTGLAZINGID.Значение = ДанныеАХ.VLH_INVENTGLAZINGID;
	нЗап.Отбор.VLH_INVENTGLAZINGID.Использование = Истина;
	
	НЗап.Прочитать(); 
	нЗап.Очистить();
	Зрег = НЗап.Добавить();
	ЗаполнитьЗначенияСвойств(Зрег, ДанныеАХ);	
		зрег.Активность = истина; 
		зрег.Период = ТекущаяДата();
		зрег.Комментарий = ДанныеАХ.ТекстОшибки;
	
	НЗап.Записать();
	

	
КонецПроцедуры

#КонецОбласти
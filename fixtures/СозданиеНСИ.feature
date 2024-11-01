﻿#language: ru

@tree

Функционал: Создание и поиск НСИ

Как Администратор я хочу
Чтобы при загрузке документов, корретно создавалась номенклатура, и обрабатывались ошибки при создании 
чтобы убрать ручные операции по НСИ 

Сценарий: <описание сценария> 



	И В командном интерфейсе я выбираю 'Работа с обменами' 'Дополнительные обработки'
	Тогда открылось окно 'Дополнительные обработки (Работа с обменами)'
	И я нажимаю на кнопку с именем 'ВыполнитьОбработку'
	Тогда открылось окно 'Проверка создания номенклатур'
	И в поле с именем 'ITEMID' я ввожу текст '01-0010'
	И в поле с именем 'CONFIGID' я ввожу текст '.L3.2'
	И в поле с именем 'INVENTCOLORID' я ввожу текст 'ИМЯ.Г'
	И в поле с именем 'INVENTSIZEID' я ввожу текст '700-1950'
	И я нажимаю на кнопку с именем 'ФормаПолучитьНоменклатуру'
	И я нажимаю на кнопку открытия поля с именем "Номенклатура"
	Тогда открылось окно 'Полотно дв. * (Номенклатура)'
	И Я закрываю окно 'Полотно дв. * (Номенклатура)'
	Тогда открылось окно 'Проверка создания номенклатур'
	И в поле с именем 'Номенклатура' я ввожу текст ''
	И в поле с именем 'ХарактеристикаНоменклатуры' я ввожу текст ''
	И я перехожу к следующему реквизиту
	И я устанавливаю флаг с именем 'ИспользоватьХарактеристики'
	И я нажимаю на кнопку с именем 'ФормаПолучитьНоменклатуру'
	И я нажимаю на кнопку открытия поля с именем "Номенклатура"
	Тогда открылось окно 'Полотно дв. * (Номенклатура)'
	И в табличном документе 'КарточкаНоменклатуры' я перехожу к ячейке "R1C1"
	И В текущем окне я нажимаю кнопку командного интерфейса 'Сопоставление кодов ах - 1с (vlh)'
	И В текущем окне я нажимаю кнопку командного интерфейса 'Основное'
	И Я закрываю окно 'Полотно дв. * (Номенклатура)'
	Тогда открылось окно 'Проверка создания номенклатур'
	И в поле с именем 'Номенклатура' я ввожу текст ''
	И в поле с именем 'ХарактеристикаНоменклатуры' я ввожу текст ''
	И я устанавливаю флаг с именем 'ИспользоватьХарактеристики'
	И в поле с именем 'ITEMID' я ввожу текст '01-0010й'
	И я нажимаю на кнопку с именем 'ФормаПолучитьНоменклатуру'
	И В командном интерфейсе я выбираю 'Работа с обменами' 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	Тогда открылось окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	И в таблице "Список" я выбираю текущую строку
	Тогда открылось окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	И Я закрываю окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	Тогда открылось окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	И в таблице 'Список' я удаляю строку
	Тогда открылось окно '1С:Предприятие'
	И я нажимаю на кнопку с именем 'Button0'
	Тогда открылось окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	И Я закрываю окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	Тогда открылось окно 'Проверка создания номенклатур'
	И я снимаю флаг с именем 'Ошибка'
	И в поле с именем 'ITEMID' я ввожу текст '31-12-83ХХ.М'
	И в поле с именем 'CONFIGID' я ввожу текст '.N'
	И я перехожу к следующему реквизиту
	И в поле с именем 'INVENTCOLORID' я ввожу текст '.ХДФ'
	И я перехожу к следующему реквизиту
	И в поле с именем 'INVENTSIZEID' я ввожу текст '8-21'
	И я нажимаю на кнопку с именем 'ФормаПолучитьНоменклатуру'
	И В командном интерфейсе я выбираю 'Работа с обменами' 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	Тогда открылось окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	И в таблице "Список" я выбираю текущую строку
	Тогда открылось окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	И Я закрываю окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	Тогда открылось окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	И в таблице 'Список' я удаляю строку
	Тогда открылось окно '1С:Предприятие'
	И я нажимаю на кнопку с именем 'Button0'
	Тогда открылось окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	И Я закрываю окно 'Ошибки создания номенклатур при загрузке из аксапты (vlh)'
	Тогда открылось окно 'Проверка создания номенклатур'
	И я снимаю флаг с именем 'Ошибка'
	И в поле с именем 'ITEMID' я ввожу текст '01-0010'
	И в поле с именем 'CONFIGID' я ввожу текст '.L3.2'
	И в поле с именем 'INVENTCOLORID' я ввожу текст 'ИМЯ.Г'
	И в поле с именем 'INVENTSIZEID' я ввожу текст '8-20'
	И я нажимаю на кнопку с именем 'ФормаПолучитьНоменклатуру'
	И я нажимаю на кнопку открытия поля с именем "Номенклатура"
	Тогда открылось окно 'Полотно дв. * (Номенклатура)'
	И в табличном документе 'КарточкаНоменклатуры' я перехожу к ячейке "R1C1"
	И Я закрываю окно 'Полотно дв. * (Номенклатура)'


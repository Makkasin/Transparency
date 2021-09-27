﻿&НаКлиенте
Процедура фФильтрГодВыпускаПриИзменении(Элемент)
	ПоказатьОтчетНаКлиенте();
КонецПроцедуры

&НаСервереБезКонтекста
Функция СоставитьМассив(пМаксимальныйЭлемент, пЭлементов, пШаг = 1)
	вМассив = Новый Массив;
	мЭлемент = пМаксимальныйЭлемент;
	
	Пока вМассив.Количество() < пЭлементов Цикл
		вМассив.Добавить(мЭлемент);
		мЭлемент = мЭлемент - пШаг;
	КонецЦикла;
	вМассив.Вставить(0, 0);
	Возврат вМассив;
КонецФункции

&НаСервере
Функция ПолучитьДанныеAPI(Сервер,порт,имяБазы)
	
	мСоединение = Новый HTTPСоединение(
									Сервер, // сервер (хост)
									Порт, // порт, по умолчанию для http используется 80, для https 443
									"SERV", // пользователь для доступа к серверу (если он есть)
									"SERVgfhjkm", // пароль для доступа к серверу (если он есть)
									, // здесь указывается прокси, если он есть
									11, // таймаут в секундах, 0 или пусто - не устанавливать
									// защищенное соединение, если используется https
									);
	
	мЗапрос = Новый HTTPЗапрос("/" + ИмяБазы + "/hs/prjapi/DATAPROZR");
	мРезультат = мСоединение.GET(мЗапрос);
	
	Если мРезультат.КодСостояния <> 200 Тогда 
		Сообщить("Ошибка отправки: " + мРезультат.КодСостояния);
		Сообщить(мРезультат.ПолучитьТелоКакСтроку());
		Возврат Неопределено;
	КонецЕсли;
	
	мЗначение = XMLЗначение(Тип("ХранилищеЗначения"), мРезультат.ПолучитьТелоКакСтроку()).Получить();
	
	тбл = мЗначение[1];
	
	
	
КонецФункции

&НаСервереБезКонтекста
Процедура ЗапуститьПолучениеДанныхВФоне(Стр)
	
	п = СтрЗаменить(Стр.ВнутреннийАдрес,":",Символы.ПС);
	Сервер = СтрПолучитьСтроку(п,1);
	порт = СтрПолучитьСтроку(п,2);
	Если порт = "" ТОгда Порт = "80"; КонецЕсли;
	порт = Число(порт);
	
	
	АдресВХранилище = ПоместитьВоВременноеХранилище(Неопределено,Новый УникальныйИдентификатор);
	
	масПар = Новый Массив;
	масПар.Добавить(Сервер);
	масПар.Добавить(Порт);
	масПар.Добавить("/"+Стр.APIrestENT+"/hs/prjapi/DATAPROZR");
	масПар.Добавить(АдресВХранилище);
	масПар.Добавить(Неопределено);
	
	фз = ФоновыеЗадания.Выполнить("глСервер.выполнитьAPI",масПар, АдресВХранилище);
	
	Стр.Ключ = АдресВХранилище;
	Стр.ид = фз.УникальныйИдентификатор;
	Стр.Выполнено = Ложь;
	
КонецПроцедуры      

&НаСервере
Процедура ОбновитьТблДанные()
	
	новстр = тблБаз.Добавить();
	новСтр.Наименование 	= "ООО НСТ";
	новстр.ВнутреннийАдрес 	= "192.168.50.11";
	новстр.APIrestENT 		= "ENT";
	новстр.APIrest 			= "BUH";
	
	эл = Элементы.Добавить("элФ"+тблБаз.Индекс(новстр),Тип("ДекорацияФормы"),Элементы.грпОрг);
	эл.Заголовок = новСтр.Наименование;
	Эл.ЦветТекста = WebЦвета.Серый;
	
	новстр = тблБаз.Добавить();
	новСтр.Наименование = "ООО МТС";
	новстр.ВнутреннийАдрес = "192.168.50.11";
	новстр.APIrestENT = "ENTMTS";
	новстр.APIrest    = "BuhMTS";
	
	эл = Элементы.Добавить("элФ"+тблБаз.Индекс(новстр),Тип("ДекорацияФормы"),Элементы.грпОрг);
	эл.Заголовок = новСтр.Наименование;
	Эл.ЦветТекста = WebЦвета.Серый;
	
	
	
	Для каждого Стр из  тблБаз Цикл
		ЗапуститьПолучениеДанныхВФоне(Стр);
	КонецЦикла;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ТблВМасСтк(Тбл) Экспорт
	
	Рез = новый Массив;
	
	сткСтр = "";
	Для каждого Кол из ТБл.Колонки Цикл
		СткСтр = СткСтр+","+Кол.Имя;
	КонецЦикла;
	СткСтр = Сред(СткСтр,2);
	
	Для каждого Стр из Тбл Цикл
		Стк = Новый Структура(СткСтр);
		ЗаполнитьЗначенияСвойств(Стк,Стр);
		Рез.Добавить(Стк);
	КонецЦикла;
	
	Возврат Рез;
	
КонецФункции
	
&НаСервереБезКонтекста
Функция ПроверитьФоновыеЗадания(идФЗ)

	рез =Неопределено;
	
	фз = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(идФЗ);
	
	Если фз<>Неопределено Тогда
		ЕСли фз.Состояние=СостояниеФоновогоЗадания.Завершено Тогда
			РезФЗ = ПолучитьИзВременногоХранилища(фз.Ключ);
			Если резФЗ<>Неопределено Тогда
				рез = ТблВМасСтк(резФЗ[1]);
			ИНаче
				Рез = Ложь;
			КонецеСЛИ;
		КонецЕсли;
	КонецеСЛИ;
	
	Возврат Рез;
	
КонецФункции

&НаКлиенте
Процедура МониторингФоновыхЗаданий() Экспорт
	
	ЕстьНеВыполнено = Ложь;
	ЕстьИзмТблДата  = Ложь;
	ДЛя каждого Стр из тблБаз Цикл 
		Если Стр.Выполнено Тогда Продолжить; КонецЕСлИ;
		
		рез = ПроверитьФоновыеЗадания(Стр.ид);
		Если Рез = Ложь Тогда //Ошибка в получении данных
			Стр.колПопыток = Стр.колПопыток+1;
			ЕСли Стр.колПопыток > 5 Тогда
				Стр.выполнено = Истина;
			ИНаче
				Стк = Новый Структура("ВнутреннийАдрес,APIrestENT,Ключ,ид,Выполнено");
				ЗаполнитьЗначенияСвойств(Стк,Стр);
				ЗапуститьПолучениеДанныхВФоне(Стк);
				ЗаполнитьЗначенияСвойств(Стр,Стк);
				
				текЭл = Элементы["ЭлФ"+тблБаз.Индекс(Стр)];
				текЭл.Заголовок = Стр.Наименование+" ("+Стр.колПопыток+")";
			КонецеСЛИ;
		ИНачеЕсли типЗнч(Рез) = Тип("Массив") Тогда
			Стр.Выполнено = Истина;
			
			Для каждого Стк из рез Цикл
				новСтр = тблДата.Добавить();
				ЗаполнитьЗначенияСвойств(новСтр,Стк);
				ЗаполнитьЗначенияСвойств(новСтр,Стр);
				
			КонецЦикла;
			
			ЕстьИзмТблДата = Истина;
			
			Элементы["ЭлФ"+тблБаз.Индекс(Стр)].ЦветТекста = WebЦвета.СинеСерый;

		КонецеСЛИ;
		
		Если Стр.Выполнено = Ложь Тогда
			ЕстьНеВыполнено = Истина;
		КонецесЛИ;
	Конеццикла;
	
	Если ЕстьНеВыполнено=Ложь Тогда
		ОтключитьОбработчикОжидания("МониторингФоновыхЗаданий");
	КонецЕСЛИ;
	
	Если ЕстьИзмТблДата Тогда
		ОбновитьКнопкиИнтерфейса();
	КонецЕсли;
	
КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОбновитьТблДанные();
	
	мМассивЛет = СоставитьМассив(Год(ТекущаяДата()), 50);
	//мМассивПростоев = СоставитьМассив(36, 6, 6);
	Элементы.фФильтрГодВыпускаС.СписокВыбора.ЗагрузитьЗначения(мМассивЛет);
	Элементы.фФильтрГодВыпускаПо.СписокВыбора.ЗагрузитьЗначения(мМассивЛет);
	
	//Элементы.ГруппаСтраницыФильтры.ТекущаяСтраница = Элементы.СтраницаФильтрыСкрыты;
	
	мОбъект = РеквизитФормыВЗначение("Объект");
	фМакет = мОбъект.ПолучитьМакет("Макет");
	
	СтрКолонокТблДата = ПолучитьСтрКолонокТблДата();
	Элементы["ФильтрВПростое00"].ЦветФона = WebЦвета.БледноЗеленый;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьПеречисленияСуперТип()
	
	МАс = новый Массив;
	Для каждого пер из Перечисления.юкСуперТипТС Цикл
		Мас.Добавить(СокрЛП(пер));
	КонецЦикла;
	
	Возврат мас;
	
КонецФункции

&НаКлиенте
Процедура ОбновитьКнопкиИнтерфейса()
	
	мСоответствиеИменФорм = Новый Соответствие;
	мСоответствиеИменФорм.Вставить("Константа", "ФормаКонстант");
	мСоответствиеИменФорм.Вставить("Обработка", "Форма");
	мСоответствиеИменФорм.Вставить("Отчет", "Форма");
	фСоответствиеИменФорм = Новый ФиксированноеСоответствие(мСоответствиеИменФорм);
	
	мСоответствиеТиповСупертипам = Новый Соответствие;
	мМассивСуперТиповВНаличии = Новый Массив;
	
	Для каждого мРезультат из тблДата Цикл
	//Пока мРезультат.Следующий() Цикл
		Если мМассивСуперТиповВНаличии.Найти(мРезультат.СуперТип) = Неопределено Тогда
			мМассивСуперТиповВНаличии.Добавить(мРезультат.СуперТип);
		КонецЕсли;
		мМассивТипов = мСоответствиеТиповСупертипам.Получить(мРезультат.СуперТип);
		мДобавляем = Ложь;
		Если мМассивТипов = Неопределено Тогда
			мМассивТипов = Новый Массив;
			мДобавляем = Истина;
		ИначеЕсли мМассивТипов.Найти(мРезультат.ТипТС) = Неопределено Тогда
		 	мДобавляем = Истина;
		КонецЕсли;
		Если мДобавляем Тогда
			мМассивТипов.Добавить(мРезультат.ТипТС);
			мСоответствиеТиповСупертипам.Вставить(мРезультат.СуперТип, мМассивТипов);
		КонецЕсли;
	КонецЦикла;
	
	//теперь пройдемся по кнопкам формы и обозначим, какие конкретно типы у нас есть (и сколько их ? тогда нужна таблица а не массив)
	Для Каждого мСуперТип Из ПолучитьПеречисленияСуперТип() Цикл//Перечисления.юкСуперТипТС Цикл
		
		мИмяСуперТипа = мСуперТип;
		мМассивТиповСуперТипа = мСоответствиеТиповСупертипам.Получить(мСуперТип);
		Если мМассивТиповСуперТипа = Неопределено Тогда
			//Сообщить("ст: " + мСуперТип);
			//Элементы["Группа" + Строка(мИмяСуперТипа)].ЦветТекстаЗаголовка = Новый Цвет(49, 89, 123);
			Для Итр = 0 По 5 Цикл
				мИмяКнопки = "" + Строка(мИмяСуперТипа) + (Итр + 1);
				Элементы[мИмяКнопки].Видимость = Ложь;
				//Элементы[мИмяКнопки].Заголовок = " --- ";
				//Элементы[мИмяКнопки].Доступность = Ложь;
			КонецЦикла;
			мИмяКнопки = "" + Строка(мИмяСуперТипа) + "0";
			Элементы[мИмяКнопки].Видимость = Ложь;
			//Элементы[мИмяКнопки].Доступность = Ложь;
			Продолжить;
			Элементы["" + Строка(мИмяСуперТипа) + "Отсутствуют"].ЦветТекста = Новый Цвет(255, 190, 190);
		КонецЕсли;
		Элементы["" + Строка(мИмяСуперТипа) + "Отсутствуют"].ЦветТекста = Новый Цвет(49, 89, 123);
		Для Итр = 0 По 5 Цикл
			мИмяКнопки = "" + Строка(мИмяСуперТипа) + (Итр + 1);
			Если Итр + 1 > мМассивТиповСуперТипа.Количество() Тогда
				Элементы[мИмяКнопки].Видимость = Ложь;
				//Элементы[мИмяКнопки].Заголовок = " --- ";
				//Элементы[мИмяКнопки].Доступность = Ложь;
				Продолжить; 
			КонецЕсли;
			Элементы[мИмяКнопки].Заголовок = мМассивТиповСуперТипа[Итр];
		КонецЦикла;
	КонецЦикла;
	фСоответствиеТиповСуперТипам = Новый ФиксированноеСоответствие(мСоответствиеТиповСупертипам);
КонецПроцедуры

&НаСервере
Функция ПолучитьСтрКолонокТблДата()
	
	РеквизитыТаблицы = ЭтаФорма.ПолучитьРеквизиты("тблДата");
	текСтр = "";
	Для каждого Реквизит из РеквизитыТаблицы Цикл
		текСтр = текСтр+","+Реквизит.Имя;
	КонецЦикла;	
	
	Возврат Сред(текСтр,2);
	
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПодключитьОбработчикОжидания("МониторингФоновыхЗаданий",1);
	//ОбновитьЭлементыФильтров("ФильтрВПростое");
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьОтчет(пИмяОтчета)
	
	
	мТекущийЭлемент = ЭтаФорма.ТекущийЭлемент;
	мИмяКнопки = мТекущийЭлемент.Имя;
	фИндексКнопки = Число(Прав(мИмяКнопки, 1));
	//получим супертип, т.к. он нужен в любом случае
	//мИмяСуперТипа = СтрЗаменить(мТекущийЭлемент.Родитель.Родитель.Родитель.Имя, "Группа", "");//можно так, если нужен другой заголовок супертипа в группе на форме
	фСуперТип = мТекущийЭлемент.Родитель.Родитель.Родитель.Заголовок;//или так, если строка заголовка совпадает с названием СуперТипа
	
	ПоказатьОтчетНаКлиенте();
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьОтчетНаКлиенте()
	Если фИндексКнопки = 0 Тогда
		//весь СуперТип
		ПоказатьОтчет(фСуперТип, Неопределено, фФильтрНаКонсервации);
	Иначе
		мМассивТиповСуперТипа = фСоответствиеТиповСуперТипам.Получить(фСуперТип);
		мТипТС = мМассивТиповСуперТипа[фИндексКнопки - 1];
		ПоказатьОтчет(Неопределено, мТипТС, фФильтрНаКонсервации);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьОтчет(пСуперТип, пТипТС, пПризнакКонсервация)
	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.СтраницаОтчет;
	//Элементы.ГруппаСтраницыФильтры.ТекущаяСтраница = Элементы.СтраницаФильтрыОтображены;
	Элементы.ГруппаКнопкаНазад.Видимость = Истина;
	
	фТабличныйДокумент = СформироватьНаСервере(фМакет, пСуперТип, пТипТС, пПризнакКонсервация, фФильтрМесяцевПростоя, фФильтрГодВыпускаС, фФильтрГодВыпускаПо);
КонецПроцедуры

&НаСервереБезКонтекста
Функция СформироватьТабДокумент(пМакет,мРезультат)
	мТабличныйДокумент = Новый ТабличныйДокумент;
	мТабличныйДокумент.АвтоМасштаб = Истина;
	мОбластьВсеЯчейки = мТабличныйДокумент.Область("C1:C100");
	мОбластьВсеЯчейки.ЦветФона = Новый Цвет(49, 89, 123);
	мОбластьВсеЯчейки.ЦветРамки = Новый Цвет(255, 255, 255);
	мОбластьВсеЯчейки.ЦветТекста = Новый Цвет(255, 255, 255);
	
	мОбластьШапкаТаблицы = пМакет.ПолучитьОбласть("Шапка");
	мОбластьГруппа = пМакет.ПолучитьОбласть("Грп");
	мОбластьСтрока = пМакет.ПолучитьОбласть("Строка");
	мОбластьШапкаТаблицы.Параметры.Дт = ТекущаяДата();
	мТабличныйДокумент.Вывести(мОбластьШапкаТаблицы);
	
	мНомерПП = 0;
		
	Для каждого мЭлементМассива Из мРезультат Цикл
		мНомерПП = мНомерПП + 1;
		мОбластьСтрока.Параметры.Заполнить(мЭлементМассива);
		мОбластьСтрока.Параметры.ном = мНомерПП;
		мТабличныйДокумент.Вывести(мОбластьСтрока);
	КонецЦикла;
	
	мТабличныйДокумент.ФиксацияСверху = 3;
	Возврат мТабличныйДокумент;
	
КонецФункции

&НаКлиенте
Функция СформироватьНаСервере(пМакет, пСуперТип, пТипТС, пПризнакКонсервация, пФильтрМесяцевПростоя, пФильтрГодВыпускаС, пФильтрГодВыпускаПо)
	
	Если пСуперТип = Неопределено Тогда
		мРезультат = ПолучитьДанные( , пТипТС, пПризнакКонсервация, пФильтрМесяцевПростоя, пФильтрГодВыпускаС, пФильтрГодВыпускаПо);
	Иначе
		мРезультат = ПолучитьДанные(пСуперТип, Неопределено, пПризнакКонсервация, пФильтрМесяцевПростоя, пФильтрГодВыпускаС, пФильтрГодВыпускаПо);
	КонецЕсли;
	
	Возврат СформироватьТабДокумент(пМакет,мРезультат);
	
КонецФункции

&НаКлиенте
Функция ПолучитьДанные(пСуперТип, пТипТС, пПризнакКонсервация, пФильтрМесяцевПростоя, пФильтрГодВыпускаС, пФильтрГодВыпускаПо)
	
	мРезультат = Новый Массив;
	Для каждого Стр из тблДата Цикл
		
		Если  пФильтрГодВыпускаС<>0 Тогда
			Если Стр.Годвыпуска < пФильтрГодВыпускаС Тогда Продолжить; КонецЕсли; 
		КонецеСЛИ;
		Если  пФильтрГодВыпускаПо<>0 Тогда
			Если Стр.Годвыпуска > пФильтрГодВыпускаПо Тогда Продолжить; КонецЕсли; 
		КонецеСЛИ;
		
		Если пПризнакКонсервация Тогда
			Если Стр.этоКонсервация = 0 ТОгда Продолжить; КонецЕсли;
		КонецЕсли;
		
		Если Стр.СуперТип <> пСуперТип  и пСуперТип<>Неопределено 	Тогда Продолжить; КонецЕсли;
		Если Стр.ТипТС	  <> пТипТС 	и пТипТС<>Неопределено 		Тогда Продолжить; КонецЕсли;
			
		Если пФильтрМесяцевПростоя > Стр.МесяцевПростоя Тогда Продолжить; КонецеСЛИ;
		
		Стк = Новый Структура(СтрКолонокТблДата);
		ЗаполнитьЗначенияСвойств(Стк,Стр);
		Стк.Вставить("нсТблДата",тблДата.индекс(стр));
		мРезультат.Добавить(Стк);
	КонецЦикла;
	
	Возврат мРезультат;
КонецФункции

&НаКлиенте
Процедура ОткрытьПоРодителю(Команда)
	мИмяЭлемента = Этаформа.ТекущийЭлемент.Имя;
	мПозицияПодчеркивания = СтрНайти(мИмяЭлемента, "_", , 2);
	Если мПозицияПодчеркивания > 0 Тогда
		мИмяЭлемента = Лев(мИмяЭлемента, мПозицияПодчеркивания - 1);
	КонецЕсли;
	мИмяВидаОбъектаМетаданных = Этаформа.ТекущийЭлемент.Родитель.Заголовок;
	мФормаИзСоответствия = фСоответствиеИменФорм.Получить(мИмяВидаОбъектаМетаданных);
	ОткрытьФорму("" + мИмяВидаОбъектаМетаданных + "." + мИмяЭлемента + "." + ?(мФормаИзСоответствия = Неопределено, ".ФормаСписка", мФормаИзСоответствия));	
КонецПроцедуры

&НаКлиенте
Процедура НадписьЗаголовокКнопкаВыходНажатие(Элемент)
	Выход(Неопределено);
КонецПроцедуры

&НаКлиенте
Процедура Выход(Команда)
	мОписаниеОповещенияОбработкаВыбораЗавершениеРаботыСистемы = Новый ОписаниеОповещения("ОбработкаВыбораЗавершениеСистемы", ЭтаФорма);
	ПоказатьВопрос(мОписаниеОповещенияОбработкаВыбораЗавершениеРаботыСистемы , "Завершить работу системы 1С?", РежимДиалогаВопрос.ДаНет);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбораЗавершениеСистемы(пРезультат, пДополнительныеПараметры) Экспорт
	Если пРезультат <> Неопределено и пРезультат = КодВозвратаДиалога.Да Тогда
		ЗавершитьРаботуСистемы(Истина, Ложь);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ФильтрПереключить(Команда)
	мИмяЭлемента = Этаформа.ТекущийЭлемент.Имя;
	ЭтаФорма["ф" + мИмяЭлемента] = НЕ ЭтаФорма["ф" + мИмяЭлемента];
	ОбновитьЭлементыФильтров(мИмяЭлемента);
	Если Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.СтраницаОтчет Тогда
		ПоказатьОтчетНаКлиенте();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ФильтрУказатьПростой(Команда)
	Элементы["ФильтрВПростое" + Прав("00" + фФильтрМесяцевПростоя, 2)].ЦветФона = WebЦвета.ЦветМорскойВолныТемный;
	мЗначение = Прав(Этаформа.ТекущийЭлемент.Имя, 2);
	фФильтрМесяцевПростоя = Число(мЗначение);
	Элементы["ФильтрВПростое" + Прав("00" + фФильтрМесяцевПростоя, 2)].ЦветФона = WebЦвета.БледноЗеленый;
	ПоказатьОтчетНаКлиенте();
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЭлементыФильтров(пИмяЭлемента)
	мРеквизит = ЭтаФорма["ф" + пИмяЭлемента];
	Элементы[пИмяЭлемента].ЦветФона = ?(мРеквизит, WebЦвета.БледноЗеленый, WebЦвета.ЦветМорскойВолныТемный);
	Элементы[пИмяЭлемента].Заголовок = ?(мРеквизит, "Вкл", "Выкл");
КонецПроцедуры

&НаКлиенте
Процедура Назад(Команда)
	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.СтраницаУправление;
	//Элементы.ГруппаСтраницыФильтры.ТекущаяСтраница = Элементы.СтраницаФильтрыСкрыты;
	Элементы.ГруппаКнопкаНазад.Видимость = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Если Не ЗавершениеРаботы И Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.СтраницаОтчет Тогда
		СтандартнаяОбработка = Ложь;
		Отказ = Истина;
		Назад(Неопределено);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьТипыТС(Команда)
	ОткрытьФорму("Справочник.уатТипыТС.ФормаСписка");
КонецПроцедуры

&НаКлиенте
Процедура Перезапуск(Команда)
	Закрыть();
	ОткрытьФорму("Обработка.ОберткаПроектПрозрачность.Форма");
КонецПроцедуры

&НаКлиенте
Процедура СбросФильтров(Команда)
	Элементы["ФильтрВПростое" + Прав("00" + фФильтрМесяцевПростоя, 2)].ЦветФона = WebЦвета.ЦветМорскойВолныТемный;
	Элементы["ФильтрВПростое00"].ЦветФона = WebЦвета.БледноЗеленый;
	фФильтрМесяцевПростоя = 0;
	фФильтрГодВыпускаС = 0;
	фФильтрГодВыпускаПо = 0;
	ПоказатьОтчетНаКлиенте();
КонецПроцедуры

&НаКлиенте
Процедура фТабличныйДокументОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка, ДополнительныеПараметры)
	СтандартнаяОбработка = Ложь;
	текСтр = тблДата[Расшифровка];
	
	мПараметры = Новый Структура("GUID_ТС", текСтр.GUID_ТС);
	мПараметры.Вставить("ГаражныйНомер", 	текСтр.ГаражныйНомер);
	мПараметры.Вставить("APIrestENT", 		текСтр.APIrestENT);
	мПараметры.Вставить("APIrest", 			текСтр.APIrest);
	мПараметры.Вставить("ВнутреннийАдрес", 	текСтр.ВнутреннийАдрес);
	
	ОткрытьФорму("ВнешняяОбработка.юкПроектПрозрачность.Форма.ФормаТранспортногоСредства", мПараметры, ЭтаФорма, , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
	
КонецПроцедуры

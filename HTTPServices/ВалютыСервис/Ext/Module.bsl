Функция ПолучитьКурсы(Запрос)
	
	Ответ = Новый HTTPСервисОтвет(200);
	
	Режим = Запрос.ПараметрыЗапроса.Получить("mode");
	
	Если Режим = "table" Тогда
		// === AJAX: таблица на дату ===
		ДатаОтчёта = Запрос.ПараметрыЗапроса.Получить("ReportDate");
		
		Если ДатаОтчёта <> Неопределено Тогда
			Попытка
				ДатаОтчёта = Дата(СтрЗаменить(ДатаОтчёта, "-", ""));
			Исключение
				ДатаОтчёта = Неопределено;
			КонецПопытки;
		КонецЕсли;
		
		Если ДатаОтчёта = Неопределено Тогда
			Ответ.УстановитьТелоИзСтроку("<p>Не удалось распознать дату</p>", КодировкаТекста.UTF8);
			Возврат Ответ;
		КонецЕсли;
		
		НовЗапрос = Новый Запрос;
		НовЗапрос.Текст = 
			"ВЫБРАТЬ
			|	КурсыВалютСрезПоследних.Валюта.Наименование КАК Валюта,
			|	КурсыВалютСрезПоследних.Курс КАК Курс,
			|	КурсыВалютСрезПоследних.Кратность КАК Кратность,
			|	КурсыВалютСрезПоследних.Период КАК ДатаУстановления
			|ИЗ
			|	РегистрСведений.КурсыВалют.СрезПоследних(&ДатаОтчёта) КАК КурсыВалютСрезПоследних";
		НовЗапрос.УстановитьПараметр("ДатаОтчёта", ДатаОтчёта);
		
		Результат = НовЗапрос.Выполнить();
		Выборка = Результат.Выбрать();
		
		HTML = "<h2>Курсы на " + Формат(ДатаОтчёта, "ДЛФ=Д") + "</h2>
		|<table class=""result-table"">
		|	<tr><th>Валюта</th><th>Курс</th><th>Кратность</th><th>Дата установки</th></tr>";
		
		Пока Выборка.Следующий() Цикл
			HTML = HTML + "
			|	<tr>
			|		<td>" + Выборка.Валюта + "</td>
			|		<td>" + Формат(Выборка.Курс, "ЧДЦ=4") + "</td>
			|		<td>" + Формат(Выборка.Кратность, "ЧДЦ=0") + "</td>
			|		<td>" + Формат(Выборка.ДатаУстановления, "ДЛФ=Д") + "</td>
			|	</tr>";
		КонецЦикла;
		HTML = HTML + "
		|</table>
		|<p class=""date-info"">Данные получены методом СрезПоследних.</p>";
		
		Ответ.Заголовки.Вставить("Content-Type", "text/html; charset=utf-8");
		Ответ.УстановитьТелоИзСтроки(HTML, КодировкаТекста.UTF8);
		
	ИначеЕсли Режим = "chart" Тогда
		// === AJAX: JSON для диаграммы ===
		ДатаНач = Запрос.ПараметрыЗапроса.Получить("StartDate");
		ДатаКон = Запрос.ПараметрыЗапроса.Получить("EndDate");
		Валюта = Запрос.ПараметрыЗапроса.Получить("Currency");
		
		Если ДатаНач <> Неопределено Тогда
			Попытка
				ДатаНач = Дата(СтрЗаменить(ДатаНач, "-", ""));
			Исключение
				ДатаНач = Неопределено;
			КонецПопытки;
		КонецЕсли;
		Если ДатаКон <> Неопределено Тогда
			Попытка
				ДатаКон = Дата(СтрЗаменить(ДатаКон, "-", ""));
			Исключение
				ДатаКон = Неопределено;
			КонецПопытки;
		КонецЕсли;
		
		Если ДатаНач = Неопределено Или ДатаКон = Неопределено Тогда
			Ответ.Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
			Ответ.УстановитьТелоИзСтроки("{""series"":[],""minVal"":0,""maxVal"":0,""error"":""period""}", КодировкаТекста.UTF8);
			Возврат Ответ;
		КонецЕсли;
		
		НовЗапрос = Новый Запрос;
		НовЗапрос.Текст = 
			"ВЫБРАТЬ
			|	КурсыВалют.Период КАК Период,
			|	КурсыВалют.Валюта.Наименование КАК Валюта,
			|	КурсыВалют.Курс КАК Курс,
			|	КурсыВалют.Кратность КАК Кратность
			|ИЗ
			|	РегистрСведений.КурсыВалют КАК КурсыВалют
			|ГДЕ
			|	КурсыВалют.Период МЕЖДУ &ДатаНач И &ДатаКон
			|УПОРЯДОЧИТЬ ПО
			|	КурсыВалют.Период";
		
		НовЗапрос.УстановитьПараметр("ДатаНач", ДатаНач);
		НовЗапрос.УстановитьПараметр("ДатаКон", ДатаКон);
		
		Если Валюта <> Неопределено И Валюта <> "" Тогда
			НовЗапрос.Текст = СтрЗаменить(НовЗапрос.Текст, "УПОРЯДОЧИТЬ ПО",
				" И КурсыВалют.Валюта.Наименование = &Валюта УПОРЯДОЧИТЬ ПО");
			НовЗапрос.УстановитьПараметр("Валюта", Валюта);
		КонецЕсли;
		
		Результат = НовЗапрос.Выполнить();
		Выборка = Результат.Выбрать();
		
		ДанныеСерий = Новый Соответствие;
		МинЗнач = 0;
		МаксЗнач = 0;
		
		Пока Выборка.Следующий() Цикл
			ИмяСерии = Строка(Выборка.Валюта);
			Если Выборка.Кратность > 1 Тогда
				ИмяСерии = ИмяСерии + " за " + Строка(Выборка.Кратность);
			КонецЕсли;
			
			Точки = ДанныеСерий.Получить(ИмяСерии);
			Если Точки = Неопределено Тогда
				Точки = Новый Массив;
				ДанныеСерий.Вставить(ИмяСерии, Точки);
			КонецЕсли;
			
			СтрДата = Формат(Выборка.Период, "ДЛФ=Д");
			Точки.Добавить(Новый Структура("Дата, Значение", СтрДата, Выборка.Курс));
			
			Если МинЗнач = 0 Или Выборка.Курс < МинЗнач Тогда
				МинЗнач = Выборка.Курс;
			КонецЕсли;
			Если Выборка.Курс > МаксЗнач Тогда
				МаксЗнач = Выборка.Курс;
			КонецЕсли;
		КонецЦикла;
		
		Если МаксЗнач > 0 Тогда
			МинЗнач = МинЗнач - 2;
			МаксЗнач = МаксЗнач + 2;
		КонецЕсли;
		
		// Сборка JSON
		JSON = "{""series"":[";
		ПерваяСерия = Истина;
		Для Каждого Элемент Из ДанныеСерий Цикл
			Если Не ПерваяСерия Тогда
				JSON = JSON + ",";
			КонецЕсли;
			ПерваяСерия = Ложь;
			
			Имя = Элемент.Ключ;
			Имя = СтрЗаменить(Имя, "\", "\\");
			Имя = СтрЗаменить(Имя, """", "\""");
			JSON = JSON + "{""name"":""" + Имя + """,""points"":[";
			
			ПерваяТочка = Истина;
			Для Каждого Точка Из Элемент.Значение Цикл
				Если Не ПерваяТочка Тогда
					JSON = JSON + ",";
				КонецЕсли;
				ПерваяТочка = Ложь;
				JSON = JSON + "{""date"":""" + Точка.Дата + """,""value"":" + Формат(Точка.Значение, "ЧГ=0; ЧРД=.") + "}";
			КонецЦикла;
			JSON = JSON + "]}";
		КонецЦикла;
		JSON = JSON + "],""minVal"":" + Формат(МинЗнач, "ЧГ=0; ЧРД=.") + ",""maxVal"":" + Формат(МаксЗнач, "ЧГ=0; ЧРД=.") + "}";
		
		Ответ.Заголовки.Вставить("Content-Type", "application/json; charset=utf-8");
		Ответ.УстановитьТелоИзСтроки(JSON, КодировкаТекста.UTF8);
		
	Иначе
		// === Главная страница с двумя вкладками ===
		
		// Получаем список валют из регистра
		ЗапросВалют = Новый Запрос;
		ЗапросВалют.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ КурсыВалют.Валюта.Наименование КАК Наименование ИЗ РегистрСведений.КурсыВалют КАК КурсыВалют УПОРЯДОЧИТЬ ПО Наименование";
		ВыборкаВалют = ЗапросВалют.Выполнить().Выбрать();
		
		ОпцииВалют = "";
		Пока ВыборкаВалют.Следующий() Цикл
			ОпцииВалют = ОпцииВалют + "<option value=""" + ВыборкаВалют.Наименование + """>" + ВыборкаВалют.Наименование + "</option>";
		КонецЦикла;
		
		HTML = "<!DOCTYPE html>
		|<html>
		|<head>
		|	<meta charset=""utf-8"">
		|	<title>Курсы валют</title>
		|	<style>
		|		body { font-family: Arial, sans-serif; margin: 30px; background: #f5f5f5; }
		|		h1 { color: #333; margin-bottom: 0; }
		|		.tabs { display: flex; gap: 0; margin-top: 20px; }
		|		.tab { padding: 10px 25px; background: #ddd; border: 1px solid #ccc; border-bottom: none; cursor: pointer; font-size: 14px; }
		|		.tab.active { background: white; font-weight: bold; }
		|		.tab-content { display: none; background: white; border: 1px solid #ccc; padding: 30px; min-height: 300px; }
		|		.tab-content.active { display: block; }
		|		form { max-width: 500px; position: relative; }
		|		label { display: block; margin-top: 15px; font-weight: bold; }
		|		.date-group { display: flex; gap: 5px; align-items: center; margin-top: 5px; }
		|		.date-group input[type=""text""] { padding: 8px; flex: 1; font-size: 14px; }
		|		.cal-btn { padding: 8px 14px; background: #6c757d; color: white; border: none; cursor: pointer; font-weight: bold; }
		|		.cal-btn:hover { background: #5a6268; }
		|		select { padding: 8px; width: 100%; box-sizing: border-box; font-size: 14px; margin-top: 5px; }
		|		.submit-btn { margin-top: 20px; padding: 10px 20px; background: #28a745; color: white; border: none; cursor: pointer; font-size: 14px; }
		|		.submit-btn:hover { background: #218838; }
		|		.calendar-popup { position: absolute; z-index: 1000; background: white; border: 1px solid #ccc; box-shadow: 2px 2px 10px rgba(0,0,0,0.2); padding: 12px; width: 230px; display: none; }
		|		.cal-header { display: flex; justify-content: space-between; margin-bottom: 10px; }
		|		.cal-header button { padding: 4px 12px; cursor: pointer; border: 1px solid #ccc; background: #f0f0f0; }
		|		.cal-header span { font-weight: bold; font-size: 14px; }
		|		.cal-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 2px; text-align: center; }
		|		.cal-grid > div { padding: 6px 0; font-size: 13px; }
		|		.cal-dow { font-weight: bold; color: #666; }
		|		.cal-day { cursor: pointer; border-radius: 3px; }
		|		.cal-day:hover { background: #007bff; color: white; }
		|		.cal-today { background: #e0e0e0; font-weight: bold; }
		|		.result-table { border-collapse: collapse; width: 100%; max-width: 600px; margin-top: 15px; }
		|		.result-table th, .result-table td { border: 1px solid #ccc; padding: 10px; text-align: left; }
		|		.result-table th { background: #f0f0f0; }
		|		.date-info { color: #555; font-style: italic; margin-top: 10px; font-size: 13px; }
		|		#tableResult, #chartContainer { margin-top: 20px; }
		|		.chart-period { display: flex; gap: 20px; flex-wrap: wrap; }
		|		.chart-period > div { flex: 1; min-width: 200px; }
		|	</style>
		|	<script>
		|		var calDate = new Date();
		|		var calTarget = null;
		|		function pad(n) { return n < 10 ? '0' + n : '' + n; }
		|
		|		function maskDate(input) {
		|			var digits = input.value.replace(/\D/g, '');
		|			if (digits.length > 8) digits = digits.substring(0, 8);
		|			var formatted = '';
		|			if (digits.length > 0) formatted += digits.substring(0, 2);
		|			if (digits.length > 2) formatted += '.' + digits.substring(2, 4);
		|			if (digits.length > 4) formatted += '.' + digits.substring(4);
		|			input.value = formatted;
		|			input.setSelectionRange(formatted.length, formatted.length);
		|		}
		|		function syncDate(val, targetId) {
		|			var p = val.split('.');
		|			if (p.length === 3) {
		|				var d = parseInt(p[0], 10);
		|				var m = parseInt(p[1], 10);
		|				var y = parseInt(p[2], 10);
		|				if (d > 0 && d < 32 && m > 0 && m < 13 && y > 1900) {
		|					document.getElementById(targetId).value = y + '-' + pad(m) + '-' + pad(d);
		|				} else {
		|					document.getElementById(targetId).value = '';
		|				}
		|			} else {
		|				document.getElementById(targetId).value = '';
		|			}
		|		}
		|		function openCalendar(targetId, event) {
		|			calTarget = targetId;
		|			var cal = document.getElementById('calendar');
		|			var rect = event.target.getBoundingClientRect();
		|			cal.style.top = (rect.bottom + window.scrollY + 5) + 'px';
		|			cal.style.left = (rect.left + window.scrollX) + 'px';
		|			cal.style.display = 'block';
		|			renderCalendar();
		|		}
		|		function closeCalendar() {
		|			document.getElementById('calendar').style.display = 'none';
		|		}
		|		function renderCalendar() {
		|			var y = calDate.getFullYear();
		|			var m = calDate.getMonth();
		|			var names = ['Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'];
		|			var firstDow = new Date(y, m, 1).getDay();
		|			if (firstDow === 0) firstDow = 7;
		|			var daysInMonth = new Date(y, m + 1, 0).getDate();
		|			var today = new Date();
		|			var isCurMonth = (today.getFullYear() === y && today.getMonth() === m);
		|			var h = '<div class=""cal-header"">';
		|			h += '<button type=""button"" onclick=""event.stopPropagation(); prevMonth()"">&#8592;</button>';
		|			h += '<span>' + names[m] + ' ' + y + '</span>';
		|			h += '<button type=""button"" onclick=""event.stopPropagation(); nextMonth()"">&#8594;</button>';
		|			h += '</div><div class=""cal-grid"">';
		|			var dows = ['Пн','Вт','Ср','Чт','Пт','Сб','Вс'];
		|			for (var i = 0; i < 7; i++) h += '<div class=""cal-dow"">' + dows[i] + '</div>';
		|			for (var i = 1; i < firstDow; i++) h += '<div></div>';
		|			for (var d = 1; d <= daysInMonth; d++) {
		|				var cls = 'cal-day';
		|				if (isCurMonth && d === today.getDate()) cls += ' cal-today';
		|				h += '<div class=""' + cls + '"" onclick=""selectDate(' + d + ')"">' + d + '</div>';
		|			}
		|			h += '</div>';
		|			document.getElementById('calendar').innerHTML = h;
		|		}
		|		function prevMonth() { calDate.setMonth(calDate.getMonth() - 1); renderCalendar(); }
		|		function nextMonth() { calDate.setMonth(calDate.getMonth() + 1); renderCalendar(); }
		|		function selectDate(day) {
		|			var y = calDate.getFullYear();
		|			var m = calDate.getMonth() + 1;
		|			document.getElementById(calTarget + 'Display').value = pad(day) + '.' + pad(m) + '.' + y;
		|			document.getElementById(calTarget).value = y + '-' + pad(m) + '-' + pad(day);
		|			closeCalendar();
		|		}
		|		document.addEventListener('click', function(e) {
		|			var cal = document.getElementById('calendar');
		|			var btns = document.querySelectorAll('.cal-btn');
		|			var onBtn = false;
		|			btns.forEach(function(b) { if (b === e.target) onBtn = true; });
		|			if (cal && cal.style.display === 'block' && !cal.contains(e.target) && !onBtn) {
		|				closeCalendar();
		|			}
		|		});
		|		function showTab(n) {
		|			document.querySelectorAll('.tab').forEach(function(t) { t.classList.remove('active'); });
		|			document.querySelectorAll('.tab-content').forEach(function(c) { c.classList.remove('active'); });
		|			document.getElementById('tabBtn' + n).classList.add('active');
		|			document.getElementById('tab' + n).classList.add('active');
		|		}
		|		function loadTable(e) {
		|			e.preventDefault();
		|			var date = document.getElementById('ReportDate').value;
		|			if (!date) { alert('Выберите дату'); return false; }
		|			document.getElementById('tableResult').innerHTML = '<p>Загрузка...</p>';
		|			fetch('/1C-800-IAR/hs/api/courses?mode=table&ReportDate=' + date)
		|				.then(function(r) { return r.text(); })
		|				.then(function(html) { document.getElementById('tableResult').innerHTML = html; })
		|				.catch(function(err) { document.getElementById('tableResult').innerHTML = '<p>Ошибка: ' + err + '</p>'; });
		|			return false;
		|		}
		|		function loadChart(e) {
		|			e.preventDefault();
		|			var sd = document.getElementById('ChartStartDate').value;
		|			var ed = document.getElementById('ChartEndDate').value;
		|			var cur = document.getElementById('CurrencySelect').value;
		|			if (!sd || !ed) { alert('Укажите период'); return false; }
		|			document.getElementById('chartContainer').innerHTML = '<p>Загрузка...</p>';
		|			var url = '/1C-800-IAR/hs/api/courses?mode=chart&StartDate=' + sd + '&EndDate=' + ed;
		|			if (cur) url += '&Currency=' + encodeURIComponent(cur);
		|			fetch(url)
		|				.then(function(r) { return r.json(); })
		|				.then(function(data) { drawChart(data); })
		|				.catch(function(err) { document.getElementById('chartContainer').innerHTML = '<p>Ошибка: ' + err + '</p>'; });
		|			return false;
		|		}
		|		function drawChart(data) {
		|			var container = document.getElementById('chartContainer');
		|			if (!data.series || data.series.length === 0) {
		|				container.innerHTML = '<p>Нет данных за выбранный период</p>';
		|				return;
		|			}
		|			var allDates = [];
		|			data.series.forEach(function(s) {
		|				s.points.forEach(function(p) {
		|					if (allDates.indexOf(p.date) === -1) allDates.push(p.date);
		|				});
		|			});
		|			allDates.sort(function(a, b) {
		|				var pa = a.split('.'), pb = b.split('.');
		|				return new Date(pa[2], pa[1]-1, pa[0]) - new Date(pb[2], pb[1]-1, pb[0]);
		|			});
		|			if (allDates.length === 0) { container.innerHTML = '<p>Нет данных</p>'; return; }
		|			var W = 650, H = 380;
		|			var m = {top: 30, right: 130, bottom: 60, left: 70};
		|			var pw = W - m.left - m.right;
		|			var ph = H - m.top - m.bottom;
		|			var minV = data.minVal, maxV = data.maxVal;
		|			if (minV === maxV) { minV -= 1; maxV += 1; }
		|			var xS = function(i) { return allDates.length === 1 ? m.left + pw/2 : m.left + (pw / (allDates.length - 1)) * i; };
		|			var yS = function(v) { return m.top + ph - ((v - minV) / (maxV - minV)) * ph; };
		|			var colors = ['#007bff','#28a745','#dc3545','#ffc107','#17a2b8','#6c757d','#e83e8c','#6f42c1'];
		|			var svg = '<svg width=""' + W + '"" height=""' + H + '"" style=""border:1px solid #ddd;background:white;"">';
		|			for (var i = 0; i <= 5; i++) {
		|				var y = m.top + (ph / 5) * i;
		|				var val = maxV - ((maxV - minV) / 5) * i;
		|				svg += '<line x1=""' + m.left + '"" y1=""' + y + '"" x2=""' + (m.left+pw) + '"" y2=""' + y + '"" stroke=""#eee""/>';
		|				svg += '<text x=""' + (m.left-8) + '"" y=""' + (y+4) + '"" text-anchor=""end"" font-size=""11"" fill=""#666"">' + val.toFixed(2) + '</text>';
		|			}
		|			var labelStep = Math.ceil(allDates.length / 8);
		|			allDates.forEach(function(date, i) {
		|				if (i % labelStep === 0 || i === allDates.length - 1) {
		|					var x = xS(i);
		|					var short = date.substring(0, 5);
		|					svg += '<text x=""' + x + '"" y=""' + (m.top+ph+18) + '"" text-anchor=""middle"" font-size=""10"" fill=""#666"">' + short + '</text>';
		|				}
		|			});
		|			svg += '<line x1=""' + m.left + '"" y1=""' + m.top + '"" x2=""' + m.left + '"" y2=""' + (m.top+ph) + '"" stroke=""#333"" stroke-width=""1.5""/>';
		|			svg += '<line x1=""' + m.left + '"" y1=""' + (m.top+ph) + '"" x2=""' + (m.left+pw) + '"" y2=""' + (m.top+ph) + '"" stroke=""#333"" stroke-width=""1.5""/>';
		|			data.series.forEach(function(s, si) {
		|				var color = colors[si % colors.length];
		|				var pathD = '';
		|				s.points.forEach(function(p, pi) {
		|					var di = allDates.indexOf(p.date);
		|					var x = xS(di), y = yS(p.value);
		|					if (pi === 0) pathD += 'M' + x + ',' + y;
		|					else pathD += ' L' + x + ',' + y;
		|				});
		|				svg += '<path d=""' + pathD + '"" fill=""none"" stroke=""' + color + '"" stroke-width=""2""/>';
		|				s.points.forEach(function(p) {
		|					var di = allDates.indexOf(p.date);
		|					svg += '<circle cx=""' + xS(di) + '"" cy=""' + yS(p.value) + '"" r=""3"" fill=""' + color + '""/>';
		|				});
		|				var ly = m.top + si * 22;
		|				svg += '<rect x=""' + (m.left+pw+10) + '"" y=""' + ly + '"" width=""12"" height=""12"" fill=""' + color + '""/>';
		|				svg += '<text x=""' + (m.left+pw+28) + '"" y=""' + (ly+10) + '"" font-size=""11"" fill=""#333"">' + s.name + '</text>';
		|			});
		|			svg += '</svg>';
		|			container.innerHTML = '<h2>Динамика курсов</h2>' + svg;
		|		}
		|	</script>
		|</head>
		|<body>
		|	<h1>Курсы валют</h1>
		|	<div class=""tabs"">
		|		<div id=""tabBtn1"" class=""tab active"" onclick=""showTab(1)"">Отчёт на дату</div>
		|		<div id=""tabBtn2"" class=""tab"" onclick=""showTab(2)"">Динамика курсов</div>
		|	</div>
		|	<div id=""tab1"" class=""tab-content active"">
		|		<h2>Отчёт курсов валют на дату</h2>
		|		<form onsubmit=""return loadTable(event)"">
		|			<label for=""ReportDateDisplay"">Дата отчёта:</label>
		|			<div class=""date-group"">
		|				<input type=""text"" id=""ReportDateDisplay"" placeholder=""дд.мм.гггг"" maxlength=""10"" oninput=""maskDate(this); syncDate(this.value, 'ReportDate')"" autocomplete=""off"">
		|				<button type=""button"" class=""cal-btn"" onclick=""openCalendar('ReportDate', event)"">...</button>
		|				<input type=""hidden"" id=""ReportDate"">
		|			</div>
		|			<button type=""submit"" class=""submit-btn"">Сформировать отчёт</button>
		|		</form>
		|		<div id=""tableResult""></div>
		|	</div>
		|	<div id=""tab2"" class=""tab-content"">
		|		<h2>Динамика курсов за период</h2>
		|		<form onsubmit=""return loadChart(event)"">
		|			<div class=""chart-period"">
		|				<div>
		|					<label for=""ChartStartDateDisplay"">Начало периода:</label>
		|					<div class=""date-group"">
		|						<input type=""text"" id=""ChartStartDateDisplay"" placeholder=""дд.мм.гггг"" maxlength=""10"" oninput=""maskDate(this); syncDate(this.value, 'ChartStartDate')"" autocomplete=""off"">
		|						<button type=""button"" class=""cal-btn"" onclick=""openCalendar('ChartStartDate', event)"">...</button>
		|						<input type=""hidden"" id=""ChartStartDate"">
		|					</div>
		|				</div>
		|				<div>
		|					<label for=""ChartEndDateDisplay"">Конец периода:</label>
		|					<div class=""date-group"">
		|						<input type=""text"" id=""ChartEndDateDisplay"" placeholder=""дд.мм.гггг"" maxlength=""10"" oninput=""maskDate(this); syncDate(this.value, 'ChartEndDate')"" autocomplete=""off"">
		|						<button type=""button"" class=""cal-btn"" onclick=""openCalendar('ChartEndDate', event)"">...</button>
		|						<input type=""hidden"" id=""ChartEndDate"">
		|					</div>
		|				</div>
		|			</div>
		|			<label for=""CurrencySelect"">Валюта:</label>
		|			<select id=""CurrencySelect"">
		|				<option value="""">Все валюты</option>
		|				" + ОпцииВалют + "
		|			</select>
		|			<button type=""submit"" class=""submit-btn"">Показать диаграмму</button>
		|		</form>
		|		<div id=""chartContainer""></div>
		|	</div>
		|	<div id=""calendar"" class=""calendar-popup""></div>
		|</body>
		|</html>";
		
		Ответ.Заголовки.Вставить("Content-Type", "text/html; charset=utf-8");
		Ответ.УстановитьТелоИзСтроки(HTML, КодировкаТекста.UTF8);
	КонецЕсли;
	
	Возврат Ответ;
	
КонецФункции

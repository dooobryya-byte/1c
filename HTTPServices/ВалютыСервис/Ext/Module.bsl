Функция ПолучитьКурсы(Запрос)
	
	Ответ = Новый HTTPСервисОтвет(200);
	
	ДатаОтчёта = Запрос.ПараметрыЗапроса.Получить("ReportDate");
	
	Если ДатаОтчёта <> Неопределено Тогда
		Попытка
			ДатаОтчёта = Дата(СтрЗаменить(ДатаОтчёта, "-", ""));
		Исключение
			ДатаОтчёта = Неопределено;
		КонецПопытки;
	КонецЕсли;
	
	Если ДатаОтчёта = Неопределено Тогда
		// === ФОРМА ===
		HTML = "<!DOCTYPE html>
		|<html>
		|<head>
		|	<meta charset=""utf-8"">
		|	<title>Отчёт по курсам валют</title>
		|	<style>
		|		body { font-family: Arial, sans-serif; margin: 40px; }
		|		form { max-width: 350px; position: relative; }
		|		label { display: block; margin-top: 15px; font-weight: bold; }
		|		.date-group { display: flex; gap: 5px; align-items: center; margin-top: 5px; }
		|		#dateDisplay { padding: 8px; flex: 1; font-size: 14px; }
		|		.cal-btn { padding: 8px 14px; background: #6c757d; color: white; border: none; cursor: pointer; font-weight: bold; font-size: 14px; }
		|		.cal-btn:hover { background: #5a6268; }
		|		.submit-btn { margin-top: 25px; padding: 10px 20px; background: #28a745; color: white; border: none; cursor: pointer; font-size: 14px; }
		|		.submit-btn:hover { background: #218838; }
		|		h1 { color: #333; }
		|		.calendar-popup { position: absolute; top: 100px; left: 0; z-index: 100; background: white; border: 1px solid #ccc; box-shadow: 2px 2px 10px rgba(0,0,0,0.2); padding: 12px; width: 230px; display: none; }
		|		.cal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
		|		.cal-header button { padding: 4px 12px; cursor: pointer; border: 1px solid #ccc; background: #f0f0f0; font-size: 14px; }
		|		.cal-header span { font-weight: bold; font-size: 14px; }
		|		.cal-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 2px; text-align: center; }
		|		.cal-grid > div { padding: 6px 0; font-size: 13px; }
		|		.cal-dow { font-weight: bold; color: #666; }
		|		.cal-day { cursor: pointer; border-radius: 3px; }
		|		.cal-day:hover { background: #007bff; color: white; }
		|		.cal-today { background: #e0e0e0; font-weight: bold; }
		|	</style>
		|	<script>
		|		var calDate = new Date();
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
		|
		|		function syncDate(val) {
		|			var p = val.split('.');
		|			if (p.length === 3) {
		|				var d = parseInt(p[0], 10);
		|				var m = parseInt(p[1], 10);
		|				var y = parseInt(p[2], 10);
		|				if (d > 0 && d < 32 && m > 0 && m < 13 && y > 1900) {
		|					document.getElementById('ReportDate').value = y + '-' + pad(m) + '-' + pad(d);
		|				} else {
		|					document.getElementById('ReportDate').value = '';
		|				}
		|			} else {
		|				document.getElementById('ReportDate').value = '';
		|			}
		|		}
		|
		|		function openCalendar() {
		|			var cal = document.getElementById('calendar');
		|			cal.style.display = (cal.style.display === 'block') ? 'none' : 'block';
		|			if (cal.style.display === 'block') renderCalendar();
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
		|			h += '<button type=""button"" onclick=""prevMonth()"">&#8592;</button>';
		|			h += '<span>' + names[m] + ' ' + y + '</span>';
		|			h += '<button type=""button"" onclick=""nextMonth()"">&#8594;</button>';
		|			h += '</div>';
		|			h += '<div class=""cal-grid"">';
		|			var dows = ['Пн','Вт','Ср','Чт','Пт','Сб','Вс'];
		|			for (var i = 0; i < 7; i++) h += '<div class=""cal-dow"">' + dows[i] + '</div>';
		|			for (var i = 1; i < firstDow; i++) h += '<div class=""cal-empty""></div>';
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
		|			document.getElementById('dateDisplay').value = pad(day) + '.' + pad(m) + '.' + y;
		|			document.getElementById('ReportDate').value = y + '-' + pad(m) + '-' + pad(day);
		|			closeCalendar();
		|		}
		|		function validateForm() {
		|			if (!document.getElementById('ReportDate').value) {
		|				alert('Выберите дату: нажмите ""..."" или введите в формате дд.ММ.гггг');
		|				return false;
		|			}
		|			return true;
		|		}
		|		document.addEventListener('click', function(e) {
		|			var cal = document.getElementById('calendar');
		|			var btn = document.querySelector('.cal-btn');
		|			if (cal && cal.style.display === 'block' && !cal.contains(e.target) && e.target !== btn) {
		|				closeCalendar();
		|			}
		|		});
		|	</script>
		|</head>
		|<body>
		|	<h1>Отчёт курсов валют на дату</h1>
		|	<p>Выберите дату, на которую нужно сформировать отчёт.</p>
		|	<form action=""/1C-800-IAR/hs/api/courses"" method=""get"" onsubmit=""return validateForm()"">
		|		<label for=""dateDisplay"">Дата отчёта:</label>
		|		<div class=""date-group"">
		|			<input type=""text"" id=""dateDisplay"" placeholder=""дд.мм.гггг"" maxlength=""10"" oninput=""maskDate(this); syncDate(this.value)"" autocomplete=""off"">
		|			<button type=""button"" class=""cal-btn"" onclick=""openCalendar()"">...</button>
		|			<input type=""hidden"" id=""ReportDate"" name=""ReportDate"">
		|		</div>
		|		<div id=""calendar"" class=""calendar-popup""></div>
		|		<button type=""submit"" class=""submit-btn"">Сформировать отчёт</button>
		|	</form>
		|</body>
		|</html>";
	Иначе
		// === ТАБЛИЦА ===
		НовыйЗапрос = Новый Запрос;
		НовыйЗапрос.Текст = 
			"ВЫБРАТЬ
			|	КурсыВалютСрезПоследних.Валюта.Наименование КАК Валюта,
			|	КурсыВалютСрезПоследних.Курс КАК Курс,
			|	КурсыВалютСрезПоследних.Кратность КАК Кратность,
			|	КурсыВалютСрезПоследних.Период КАК ДатаУстановления
			|ИЗ
			|	РегистрСведений.КурсыВалют.СрезПоследних(&ДатаОтчёта) КАК КурсыВалютСрезПоследних";
		
		НовыйЗапрос.УстановитьПараметр("ДатаОтчёта", ДатаОтчёта);
		
		Результат = НовыйЗапрос.Выполнить();
		Выборка = Результат.Выбрать();
		
		HTML = "<!DOCTYPE html>
		|<html>
		|<head>
		|	<meta charset=""utf-8"">
		|	<title>Отчёт: курсы на " + Формат(ДатаОтчёта, "ДЛФ=Д") + "</title>
		|	<style>
		|		body { font-family: Arial, sans-serif; margin: 40px; }
		|		table { border-collapse: collapse; width: 500px; margin-top: 20px; }
		|		th, td { border: 1px solid #ccc; padding: 10px; text-align: left; }
		|		th { background: #f0f0f0; }
		|		h1 { color: #333; }
		|		.back-link { margin-top: 30px; }
		|		.date-info { color: #555; font-style: italic; }
		|	</style>
		|</head>
		|<body>
		|	<h1>Курсы валют на дату: " + Формат(ДатаОтчёта, "ДЛФ=Д") + "</h1>
		|	<p class=""date-info"">Данные получены методом СрезПоследних на указанную дату.</p>
		|	<table>
		|		<tr><th>Валюта</th><th>Курс</th><th>Кратность</th><th>Дата установки</th></tr>";
		
		Пока Выборка.Следующий() Цикл
			HTML = HTML + "
			|		<tr>
			|			<td>" + Выборка.Валюта + "</td>
			|			<td>" + Формат(Выборка.Курс, "ЧДЦ=4") + "</td>
			|			<td>" + Формат(Выборка.Кратность, "ЧДЦ=0") + "</td>
			|			<td>" + Формат(Выборка.ДатаУстановления, "ДЛФ=Д") + "</td>
			|		</tr>";
		КонецЦикла;
		
		HTML = HTML + "
		|	</table>
		|	<div class=""back-link"">
		|		<a href=""/1C-800-IAR/hs/api/courses"">← Вернуться к выбору даты</a>
		|	</div>
		|</body>
		|</html>";
	КонецЕсли;
	
	Ответ.Заголовки.Вставить("Content-Type", "text/html; charset=utf-8");
	Ответ.УстановитьТелоИзСтроки(HTML, КодировкаТекста.UTF8);
	
	Возврат Ответ;
	
КонецФункции

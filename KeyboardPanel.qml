import QtQuick 1.1

FocusScope {
	id: keyboardPanel

	height: parent.height
	width: parent.width

	// Keyboard Properties
	property string languageSelected: "eng";	//in case we need to have alt keyboards
	property string strPlaceholderText: "Begin typing to search";
	property string strKeyboardText: "";
	property bool bIsShifted: false;	//SHIFT mode - will reset on keypress
	property bool bIsCaps: false;	//CAPS mode
	property bool bIsSymbols: false;	//Symbols mode
	property var rowSelected;
	property bool bHandsetUsed: false;
	property bool bDebugOn: false;
	property string imagePath: "./";

	// Text Box Properties
	property int maxCharCount: 500;

	Rectangle {
		id: background;
		color: "transparent";

		Rectangle {
			id: textInputBox;
			color: "transparent"
			width: parent.width*0.8;
			height: paarent.height*0.2;

			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.top: parent.top;


			TextEdit {
				id: keyboardTextBox;
				anchors.fill: parent;
				anchors.margins: 5;

				focus: true;
				clip: true;

				font.family: "Arial";
				font.pixelSize: 20;

				cursorVisible: true;
				wrapMode: TextEdit.Wrap;
				text: strKeyboardText;
			}
		}
	}

	// ORIGINAL ROWS

	property var rows: [
		["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "_backspace"],
		["_caps", "a", "s", "d", "f", "g", "h", "j", "k", "l", "_return"],
		["_shift", "z", "x", "c", "v", "b", "n", "m", ",", ".", "_matchtop"],
		["_symbols", "_spacebar", "_up", "_down", "_left", "_right", "_exit"]
	]

	property var rowsCode: [
		["", "", "", "", "", "", "", "", "", "", 0x0008],
		["", "", "", "", "", "", "", "", "", "", "" ],
		["", "", "", "", "", "", "", "", "", "", "" ],
		["", 0x0020, "", "", "", "", ""]
	]

	property var rowsCapitals: [
		["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "_backspace"],
		["_caps", "A", "S", "D", "F", "G", "H", "J", "K", "L", "_return"],
		["_shift", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "_matchtop"],
		["_symbols", "_spacebar", "_up", "_down", "_left", "_right", "_exit"]
	]

	property var rowsCapitalsCode: [
		["", "", "", "", "", "", "", "", "", "", 0x0008],
		["", "", "", "", "", "", "", "", "", "", "" ],
		["", "", "", "", "", "", "", "", "", "", "" ],
		["", 0x0020, "", "", "", "", ""]
	]

	property var rowsSymbols: [
		["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "_backspace"],
		["\\", ":", ";", "(", ")", ">", "$", "&", "@", "\"", "_return"],
		["?", "!", "\'", "^", "*", "%", "#", "-", ",", ".", "_matchtop"],
		["_symbols", "_spacebar", "_up", "_down", "_left", "_right", "_exit"]
	]

	property var rowsSymbolsCode: [
		["", "", "", "", "", "", "", "", "", "", 0x0008],
		["", "", "", "", "", "", "", "", "", "", "" ],
		["", "", "", "", "", "", "", "", "", "", "" ],
		["", 0x0020, "", "", "", "", ""]
	]

	//array in progress for special chars
	property var specialChars: [
		{"o":[{"char":"ò","code":""},{"char":"õ","code":""},{"char":"ö","code":""},{"char":"ó","code":""},{"char":"ô","code":""}],"alignment":"right"},
		{"w":[{"char":"Ŵ","code":""}],"alignment":"left"},
		{"W":[{"char":"Ŵ","code":""}],"alignment":"left"},
	]

	property var rowsGroup:			{"char": rows,			"code": rowsCode}
	property var rowsCapitalsGroup:	{"char": rowsCapitals,	"code": rowsCapitalsCode}
	property var rowSymbolsGroup:	{"char": rowsSymbols,	"code": rowsSymbolsCode}

	//arrays will be read in using something similar to


	//	ListModel {
	//		id: model

	//		signal loadCompleted()

	//		Component.onCompleted: {
	//			var xhr = new XMLHttpRequest;
	//			xhr.open("GET", "layouts//"+ selectedLang + "//myfile.txt");
	//			xhr.onreadystatechange = function() {
	//				if (xhr.readyState == XMLHttpRequest.DONE) {
	//					var a = JSON.parse(xhr.responseText);
	//					for (var b in a) {
	//						var o = a[b];
	//						model.append({label: o.label, value: o.value, description: o.description, image: o.image, selected: false});
	//					}
	//					model.loadCompleted()
	//				}
	//			}
	//			xhr.send();
	//		}
	//	}


	Image {
		id: keyboardContainerImage
		source: imagePath + "images/background_kb.png"
		anchors.left: parent.left
		anchors.bottom: parent.bottom

		MouseArea {
			anchors.fill: parent
			onPressed: {
				return;
			}
		}
	}

	// START ROW SETUP
	Column {
		id: layout
		width: keyboardContainerImage.width;
		height: keyboardContainerImage.height;
		Repeater {
			id: repeater;
			model: rowsGroup.length;
			focus: true;
			KeyboardListView {
				rowNumber: index;
				modelSet: selectListToUse();
				focus: true;
				delegate: KeyboardButton {
					target: keyboardTextBox;
				}
				listAbove: repeater.itemAt(index-1);
				listBelow: repeater.itemAt(index+1);
				Keys.onLeftPressed:		moveColumn("left",	repeater.itemAt(rowNumber));
				Keys.onRightPressed:	moveColumn("right",	repeater.itemAt(rowNumber));
				Keys.onDownPressed:		moveRow("down",		repeater.itemAt(rowNumber));
				Keys.onUpPressed:		moveRow("up",		repeater.itemAt(rowNumber));
			}
		}
	}

	// END ROW SETUP

	// START TESTING IMPLEMENTS

	Rectangle {
		id: locationPingX
		color: "red"
		width: 2
		height: parent.height
		x: 0
		y: 0

		visible: bDebugOn;
	}

	Rectangle {
		id: locationPingY
		color: "red"
		width: parent.width
		height: 2
		x: 0
		y: 0

		visible: bDebugOn;
	}

	// END TESTING IMPLEMENTS


	// START FUNCTIONS

	function moveColumn(direction, onRow) {
		if(bDebugOn)
			write.out("moveColumn() called --- " + direction);
		var foundColumn = false;
		var iteration = 0;
		while (!foundColumn) {
			iteration++;
			if (direction === "left") {
				if ((onRow.currentIndex-iteration) !== -1) {
					if (!onRow.model[(onRow.currentIndex-iteration)].contains("blank")) {
						onRow.currentIndex = (onRow.currentIndex-iteration);
						foundColumn = true;
					}
				}
				else {
					return;
				}
			}
			else if (direction === "right") {
				if ((onRow.currentIndex+iteration) < onRow.count) {
					if (!onRow.model[(onRow.currentIndex+iteration)].contains("blank")) {
						onRow.currentIndex = (onRow.currentIndex+iteration);
						foundColumn = true;
					}
				}
				else {
					return;
				}
			}
			//DEBUG CODE.
			if (bDebugOn) {
				locationPingX.x = onRow.currentItem.x+(onRow.currentItem.width/2)+onRow.listViewSpacing
				locationPingY.y = onRow.y+(onRow.height/2)
			}
		}
	}

	function moveRow(direction, fromRow) {
		write.out("moveRow() called --- " + direction)
		var toRow;
		var foundRow = false;
		while(!foundRow) {
			if (direction === "up" && (fromRow.listAbove != null && fromRow.listAbove != undefined)) {
				toRow = fromRow.listAbove;
			}
			else if (direction === "down" && (fromRow.listBelow != null && fromRow.listBelow != undefined)) {
				toRow = fromRow.listBelow;
			}
			else {
				write.out("Navigation Bailing (" + direction + ").")
				write.out("Bail Debug || fromRow.listBelow: " + fromRow.listBelow + " || fromRow.listAbove: " + fromRow.listAbove)
				return;
			}
			//			write.out("toRow: " + toRow + " || fromRow: " + fromRow)
			var xPosition = fromRow.currentItem.x+(fromRow.currentItem.width/2);
			var positionToMoveTo = toRow.indexAt(xPosition, 0);
			if (positionToMoveTo === -1) {
				positionToMoveTo = toRow.indexAt(xPosition+toRow.listViewSpacing, 0);
			}
			toRow.currentIndex = positionToMoveTo;

			if (toRow.currentItem.buttonText.contains("blank")) {
				fromRow = toRow;
			}
			else {
				toRow.focus = true;
				foundRow = true;
			}
			// DEBUG CODE.
			if (bDebugOn) {
				locationPingX.x = xPosition+toRow.listViewSpacing
				locationPingY.y = toRow.y+(toRow.height/2)
			}
		}
	}

	function selectListToUse() {
		// use bool settings to determine layout
		//if we are in shift mode or caps mode, but not shift+caps AND not symbol mode
		if (((bIsShifted || bIsCaps) && !(bIsShifted && bIsCaps)) && !bIsSymbols) {
			return rowsCapitalsGroup;
		}
		//if we are shift+caps or not shift or caps AND not symbols
		else if (((bIsShifted && bIsCaps) || !(bIsShifted && bIsCaps)) && !bIsSymbols) {
			return rowsGroup;
		}
		//clearly we are symbol mode if symbol mode is on
		else if (bIsSymbols) {
			return rowSymbolsGroup;
		}
	}

	function closeKeyboard(save) {
		//		write.out("closeKeyboard() called --- ")
		if (save) {
			keyboardTextContainer = keyboardTextBox.text;
		}
	}

	// END FUNCTIONS

	Component.onCompleted: {
		languageSelected = "eng";	//in theory this could be done using ISO codes - language switching to be done
		keyboardTextBox.cursorPosition = keyboardTextBox.text.length;
		keyboardPanel.focus = true;
	}
}

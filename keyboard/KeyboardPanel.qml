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

	// Text Box Properties
	property int maxCharCount: 500;

	Connections {
		target: main
		onBHandsetActiveChanged: {
			if (bHandsetActive) {
				rowSelected.forceActiveFocus();
				keyboardTextBox.cursorVisible = true;
			}
		}
	}

	MouseArea {
		id: stopTouchesToTheGauzeBehind

		anchors.fill: parent

		onClicked: {
			//do nothing. this is the whole point of my existence here.
		}
	}

	Image {
		id: background
		source: imagePath + "images/text_input_field_and_BG.png"

		Rectangle {
			id: textInputPlaceholder
			color: "transparent"
			width: 1050
			height: 160

			anchors.left: parent.left
			anchors.top: parent.top
			anchors.leftMargin: 115
			anchors.topMargin: 107


			TextEdit {
				id: keyboardTextBox
				anchors.fill: parent
				anchors.leftMargin: 5
				anchors.topMargin: 5

				focus: true
				clip: true

				font.family: fonts.araRegular
				font.pixelSize: 20

				cursorVisible: true
				wrapMode: TextEdit.Wrap
				text: strKeyboardText;

				onTextChanged: {
					if (handsetUsed) {
						if (rowSelected != null && rowSelected != undefined) {
							rowSelected.forceActiveFocus();
						}
						else {
							firstRowListView.forceActiveFocus();
						}
						handsetUsed = false;
					}
				}
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
		["~", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-"],
		["_language", "~", "`", "%", "*", "<", ">", "[", "]", "{", "}", "_backspace"],
		["_tab", ".", "$", "&", "_", "(", ")", ":", ";", "\"", "_return"],
		["_shift", "\u263A", "!", "#", "=", "/", "+", "?", "@", "_shift"],
		["_symbols", "-", "_spacebar", "\'", "_exit"]
	]

	property var rowsSymbolsCode: [
		["", "", "", "", "", "", "", "", "", "", "", ""],
		["", "", "", "", "", "", "", "", "", "", "", 0x0008],
		[0x0009, "", "", "", "", "", "", "", "", "", 0x23CE],
		["", "", "", "", "", "", "", "", "", ""],
		["", "", 0x0020, "", ""]
	]

	//
	property var specialChars: [
		{"o":[{"char":"ò","code":""},{"char":"õ","code":""},{"char":"ö","code":""},{"char":"ó","code":""},{"char":"ô","code":""}],"alignment":"right"},
		{"w":[{"char":"Ŵ","code":""}],"alignment":"left"},
		{"W":[{"char":"Ŵ","code":""}],"alignment":"left"},
	]

	property var rowsGroup:			{"char": rows,			"code": rowsCode}
	property var rowsCapitalsGroup:	{"char": rowsCapitals,	"code": rowsCapitalsCode}
	property var rowSymbolsGroup:	{"char": rowsSymbols,	"code": rowsSymbolsCode}

	Image {
		id: keyboardContainerImage
		source: imagePath + "images/keyboard_bg.png"
		anchors.left: parent.left
		anchors.bottom: parent.bottom

		MouseArea {
			anchors.fill: parent
			onPressed: {
				return;
			}
		}

		// START ROW SETUP

		KeyboardListView {
			id: firstRowListView
			anchors.left: parent.left;
			anchors.leftMargin: 5;
			anchors.top: parent.top;
			anchors.topMargin: -2;

			rowNumber: 0;
			modelSet: selectListToUse();
			listBelow: secondRowListView;

			focus: true;

			delegate: KeyboardButton {}

			Keys.onLeftPressed:		moveColumn("left",	firstRowListView);
			Keys.onRightPressed:	moveColumn("right",	firstRowListView);
			Keys.onDownPressed:		moveRow("down",		firstRowListView);
			Keys.onUpPressed:		null; //put the focus on topbar buttons
		}

		KeyboardListView {
			id: secondRowListView
			anchors.left: firstRowListView.left
			anchors.top: firstRowListView.bottom

			rowNumber: 1;
			modelSet: selectListToUse();
			listAbove: firstRowListView
			listBelow: thirdRowListView

			delegate: KeyboardButton {}

			Keys.onLeftPressed:		moveColumn("left",	secondRowListView);
			Keys.onRightPressed:	moveColumn("right",	secondRowListView);
			Keys.onUpPressed:		moveRow("up",		secondRowListView);
			Keys.onDownPressed:		moveRow("down",		secondRowListView);
		}

		KeyboardListView {
			id: thirdRowListView
			anchors.left: firstRowListView.left
			anchors.top: secondRowListView.bottom

			rowNumber: 2;
			modelSet: selectListToUse();
			listAbove: secondRowListView
			listBelow: forthRowListView

			delegate: KeyboardButton {}

			Keys.onLeftPressed:		moveColumn("left",	thirdRowListView);
			Keys.onRightPressed:	moveColumn("right",	thirdRowListView);
			Keys.onUpPressed:		moveRow("up",		thirdRowListView);
			Keys.onDownPressed:		moveRow("down",		thirdRowListView);
		}

		KeyboardListView {
			id: forthRowListView
			anchors.left: firstRowListView.left
			anchors.top: thirdRowListView.bottom

			rowNumber: 3;
			modelSet: selectListToUse();
			listAbove: thirdRowListView

			delegate: KeyboardButton {}

			Keys.onLeftPressed:		moveColumn("left",	forthRowListView);
			Keys.onRightPressed:	moveColumn("right",	forthRowListView);
			Keys.onUpPressed:		moveRow("up",		forthRowListView);
			Keys.onDownPressed:		null; //put focus on bottombar buttons
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
	}

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
//		write.out("moveRow() called --- " + direction)
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
		firstRowListView.forceActiveFocus();
	}
}

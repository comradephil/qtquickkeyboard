import QtQuick 1.1

Image {
	property string buttonText: ListView.model[index];
	property variant buttonCode: ListView.model[index];
	property string sourceString: "";
	property string sourceStringHighlight: "";
	property string sourceStringPressed: "";
	property bool isHighlighted: (ListView.currentIndex === index && activeFocus) ? true : false;
	property string testIndex: index;
	property string fontSetting: "";
	property bool mousePressed: false;
	property var target;

	source: imagePath + checkImage();

	Image {
		id: innerImage
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter

		source: checkIconImage();
	}

	Text {
		id: keyboardButtonText
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter
		color: "white"

		font.pixelSize: 32

		font.family: fontSetting

		text: {
			if (buttonText.contains("_") && buttonText.length > 1) {
				return "";
			}
			else {
				return buttonText;
			}
		}
	}

	Keys.onReleased: {
		if(munchUserInput) { event.accepted = true; return; }
		if(event.key === Qt.Key_Return) {
			handsetUsed = true;
			buttonAction();
			event.accepted = true;
		}
	}

	MouseArea {
		anchors.fill: parent

		onPressed: {
			mousePressed = true;
		}

		onReleased: {
			mousePressed = false;
			buttonAction();
		}
	}

	function buttonAction() {
		write.out("The " + buttonText + " button has been pressed...");
		if (buttonText.contains("lang")) {
			write.out("Switching Language.");
			languageSelected = "eng";
		}
		else if (buttonText.contains("shift")) {
			bIsShifted = !bIsShifted;
		}
		else if (buttonText.contains("symbols")) {
			isSymbols = !isSymbols;
		}
		else if (buttonText.contains("exit")) {
			closeKeyboard(false)
		}
		else {
			if (buttonText.contains("backspace")) {
				var partOne = keyboardTextBox.text.slice(0, keyboardTextBox.cursorPosition > 0 ? keyboardTextBox.cursorPosition-1 : 0);
				var partTwo = keyboardTextBox.text.slice(keyboardTextBox.cursorPosition, keyboardTextBox.text.length);
				keyboardTextBox.text = partOne + partTwo
				keyboardTextBox.cursorPosition = partOne.length
				return;
			}

			if (keyboardTextBox.text.length < maxCharCount) {
				var partOne = keyboardTextBox.text.slice(0, keyboardTextBox.cursorPosition);
				var partTwo = keyboardTextBox.text.slice(keyboardTextBox.cursorPosition, keyboardTextBox.text.length);
				var beforeKey = partOne

				if (buttonText.contains("blank")) {
					return;
				}
				if (buttonText.contains("spacebar")) {
					partOne = partOne + " ";
				}
				else if (buttonText.contains("return")) {
					partOne = partOne + "\n"
				}
				else if (buttonText.contains("tab")) {
					partOne = partOne + "	";
				}
				else if (buttonCode === "") {
					partOne = partOne + buttonText
				}

				keyboardTextBox.text = partOne + partTwo;
				keyboardTextBox.cursorPosition = partOne.length

				if(keyboardTextBox.cursorRectangle.y + keyboardTextBox.cursorRectangle.height > textInputPlaceholder.height) {
					keyboardTextBox.text = beforeKey + partTwo
					keyboardTextBox.cursorPosition = beforeKey.length
				}

				return;
			}
		}
	}

	function checkImage() {
		var languageToUse = languageSelected;

		if (buttonText == undefined && buttonText == null) {
			return;
		}
		if (sourceString !== "" && sourceString !== null & sourceString !== undefined) {
			if (!isHighlighted) {
				return sourceString;
			}
			else {
				return sourceStringHighlight;
			}
		}
		else if (buttonText.contains("blank")) {
			return "images/" + languageToUse.toLowerCase() + "/" + buttonText.substring(1, buttonText.length) + ".png";
		}
		else if (buttonText === "\u060C" || buttonText === "\u06D4") {
			return "images/" + languageToUse.toLowerCase() + "/large_letters" + ((isHighlighted) ? "_handset" : "_default") + ".png";
		}
		else if (buttonText.contains("_") && buttonText.length > 1) {
			return "images/" + languageToUse.toLowerCase() + "/" + buttonText.substring(1,buttonText.length) + ((isHighlighted) ? "_handset" : "_default") + ".png";
		}
		else {
			return "images/" + languageToUse.toLowerCase() + "/letters" + ((isHighlighted) ? "_handset" : "_default") + ".png";
		}
	}

	function checkIconImage() {
		if (buttonText == undefined && buttonText == null) {
			return;
		}
		if (buttonText.contains("_shift")) {
			return imagePath + "images/icon_" + buttonText.substring(1, buttonText.length) + ((bIsShifted) ? "_on" : "_off") + ".png"
		}
		else if (buttonText.contains("_") && buttonText.length > 1 && !buttonText.contains("blank") && !buttonText.contains("spacebar")) {
			return imagePath + "images/icon_" + buttonText.substring(1, buttonText.length) + ".png";
		}
		else {
			return "";
		}
	}
}

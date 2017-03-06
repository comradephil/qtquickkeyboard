import QtQuick 1.1

ListView {
	id: keyboardListView

	property int listViewSpacing: 2;
	property variant listAbove;
	property variant listBelow;
	property variant modelSet;
	property int rowNumber;

	spacing: listViewSpacing

	anchors.topMargin: listViewSpacing

	interactive: false;
	orientation: ListView.Horizontal
	model: modelSet["char"][rowNumber];

	width: parent.width
	height: contentItem.childrenRect.height

	delegate: KeyboardButton {
		buttonText: keyboardListView.model[index];
		isHighlighted: (keyboardListView.currentIndex === index && activeFocus) ? true : false;
	}

	Rectangle {
		color: "yellow"
		width: parent.width
		height: 1
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 5

		visible: (bDebugOn && keyboardPanel.rowSelected === parent)
	}

	onActiveFocusChanged: {
		write.out("Row Number " + rowNumber + " has set activeFocus to " + activeFocus)
		if (activeFocus) {
			write.out("keyboardPanel.rowSelected: " + keyboardPanel.rowSelected)
			keyboardPanel.rowSelected = keyboardListView;
		}
	}
}

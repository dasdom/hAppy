var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();
var tableView = window.tableViews()[0];
var cell = tableView.cells()[0];
cell.logElementTree();
cell.tapWithOptions({tapOffset:{x:0.1, y:0.1}});
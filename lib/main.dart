import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Time Zipper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Event> events = new List<Event>();
  int _selectedIndex = 0;
  final controller = PageController(initialPage: 0);
  String value;
  double slidervalue;
  int time;
  TimeOfDay t;
  TextEditingController textCon1 ;
  TextEditingController textCon2 ;
  List<Widget> eventList = new List<Widget>();
  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
      controller.jumpToPage(index);
    });
  }
  void _onTap(){
    setState(() {
      slidervalue = 5.0;
      value = "Essay";
      textCon1 = new TextEditingController();
      textCon2 = new TextEditingController();
      t = new TimeOfDay.now();
      showDialog(
          context: context,
          builder: (BuildContext context){
            return new SimpleDialog(
              title: Text("Enter Info"),
              children: <Widget>[
                TextField(
                  autofocus: true,
                  controller: textCon1,
                  decoration: InputDecoration(
                    labelText: "Task Name",
                    hintText: "math homework",
                    prefixIcon: Icon(Icons.border_color)
                  ),
                ),
                TextField(
                  autofocus: true,
                  controller: textCon2,
                  decoration: InputDecoration(
                    labelText: "Time Needed(mins)",
                    hintText: "60",
                    prefixIcon: Icon(Icons.timer)
                  ),
                ),
                Wrap(
                  spacing: 2.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(9.0),
                      child: Icon(Icons.category, color: Colors.red,),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text("Category", style: TextStyle(fontSize: 12.0, color: Colors.red),),
                    ),
                    DropdownButton<String>(
                      value: value,
                      onChanged: (String newValue){
                        setState(() {
                          value = newValue;
                        });
                      },
                      items: <String> ["Essay", "Group Project", "Worksheet", "Test Paper"]
                          .map<DropdownMenuItem<String>>((String value){
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 2.0,
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(9.0),
                      child: Icon(Icons.notification_important, color: Colors.red,),
                    ),
                    Padding(padding: EdgeInsets.all(4.0),
                    child: Text("Importance", style: TextStyle(fontSize: 12.0, color: Colors.red),),),
                    CupertinoSlider(
                        value: slidervalue,
                        max: 10.0,
                        min: 0.0,
                        activeColor: Colors.red,
                        divisions: 10,
                        onChanged: (double val){
                          setState(() {
                            slidervalue = val;
                            //print(val);
                          });
                        }
                    )
                  ],
                ),
                Padding(
                    padding: EdgeInsets.all(12.0),
                    child: RaisedButton(
                            child: Text("Select Deadline", style: TextStyle(color: Colors.white, fontSize: 15.0),),
                            elevation: 4.0,
                            highlightColor: Colors.grey,
                            color: Colors.lightBlueAccent[700],
                            splashColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                            onPressed: (){
                            showTimePicker(
                              context: context,
                              initialTime: t,
                            ).then((val) {
                              t = val;
                            });
            }
            ),
                ),

                SimpleDialogOption(
                  child: Text("Confirm", style: TextStyle(color: Colors.blue, fontSize: 15.0),),
                  onPressed: _onAdd
                )
              ],
            );
          }
      );
    });
  }
  String timeString(TimeOfDay t){
    String ts = (t.minute<10)?"0"+t.minute.toString():t.minute.toString();
    return t.hour.toString()+":"+ts;

  }
  List<Color> colorChooser(String v){
    switch(v){
      case "Essay":
        return [Colors.blue, Colors.lightBlueAccent];
        break;
      case "Group Project":
        return [Colors.red, Colors.orangeAccent];
        break;
      case "Worksheet":
        return [Colors.green, Colors.lightGreenAccent];
        break;
      case "Test Paper":
        return [Colors.indigo, Colors.blueAccent];
        break;
      default:
        break;

    }
    return [Colors.black, Colors.grey];
  }
  void _onAdd(){
    setState(() {
        Navigator.of(context).pop();
        print("\n Task Name: "+textCon1.text+
            "\n Time Needed: "+textCon2.text+
            "\n Category: "+value+
            "\n Importance: $slidervalue"+
            "\n Deadline: "+timeString(t)
        );
        Event newEvent = new Event(textCon1.text, value, int.parse(textCon2.text), slidervalue, t);
        int i = 0;
        while(true){
          if(events.length==0){events.add(newEvent); break;}
          if(newEvent.isEarlier(events[i])) {
            events.insert(i, newEvent);
            break;
          }
          else if(i==events.length-1){
            events.add(newEvent);
          }
          i++;
        }
        eventList.insert(i,
            new GradientButton(
                index: eventList.length,
                colors: colorChooser(value),
                width: MediaQuery.of(context).size.width-40.0,
                height: 70.0,
                child: Text(textCon1.text+"\nFinished Before "+timeString(t),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                  ),
                )
            )
        );


    });
  }
  void _onEvent(int index){
    setState(() {
        Event e = events[index];
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context){
            return new AlertDialog(
              title: Text("Current Task"),
              content:new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new Text("Task Name: "+e.name),
                      new Text("Time Needed: "+e.time.toString()),
                      new Text("Category: "+e.category),
                      new Text("Importance: "+e.imp.toString()),
                      new Text("Deadline: "+timeString(e.deadline)),
                      new Padding(
                        padding: EdgeInsets.only(top:20.0),
                        child: new Text(
                          "Please Complete Tasks\n in ORDER!!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20.0, color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
              ),),

              actions: <Widget>[
                new FlatButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text("Close", style: TextStyle(color: Colors.blue),),
                )
              ],
            );
          }
        );
    });
  }
  void _completeEvent(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Complete Confirmation"),
          content: Text("Are you sure that this task has been finished?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Confirmed"),
              onPressed: (){
                Navigator.of(context).pop();
                events.removeAt(0);
                eventList.removeAt(0);
              },
            ),
            FlatButton(
              child: Text("Cancel"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.notification_important),
              onPressed: (){
                if(events.length!=0) _onEvent(0);
              }
              ),
        ],
        leading: Builder(builder: (context){
          return IconButton(
              icon: Icon(Icons.person), onPressed: (){
                Scaffold.of(context).openDrawer();
          }
          );
        }),

      ),
      drawer: new MyDrawer(),
      bottomNavigationBar: BottomNavigationBar(
          items:<BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Tablet')),
            BottomNavigationBarItem(icon: Icon(Icons.data_usage), title: Text('statistics')),
            BottomNavigationBarItem(icon: Icon(Icons.perm_data_setting), title: Text('customization')),

          ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.red,
        onTap: _onItemTapped,
      ),

      body: PageView(
        controller: controller,
        children: <Widget>[
          Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.center,
                    children: eventList
                  ),
                  new Padding(padding: EdgeInsets.all(25.0), child: new RaisedButton(
                      color: Colors.blue,
                      elevation: 4.0,
                      padding: EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      child: Icon(Icons.delete_outline,color: Colors.white,),
                      onPressed: _completeEvent
                  ),)

                ],
              )
            )
          ),


          Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  new Padding(padding: EdgeInsets.all(16.0), child: Text("The Test for Stats", style: TextStyle(color: Colors.blue, fontSize: 30.0, fontWeight: FontWeight.bold),),),
                  new Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200.0,
                    child: AnimatePie(),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Animate Pie Chart For Data Visualization", style: TextStyle(fontSize: 15.0),),
                  ),
                  new Container(
                    width: MediaQuery.of(context).size.width-40.0,
                    height: 200.0,
                    child: SimpleBarChart.withSampleData(),
                  ),
                  new Container(
                    padding: EdgeInsets.only(top:20.0),
                    width: MediaQuery.of(context).size.width-40.0,
                    height: 400.0,
                    child: new DataTable(

                        columns: [
                          DataColumn(label: Text("Category")),
                          DataColumn(label: Text("Average\n Time")),
                          DataColumn(label: Text("Average\n Importance")),
                          DataColumn(label: Text("Total\n Hours")),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text("Essay")),
                            DataCell(Text("30")),
                            DataCell(Text("4")),
                            DataCell(Text("120")),
                          ]),
                          DataRow(cells: [
                            DataCell(Text("Group Project")),
                            DataCell(Text("50")),
                            DataCell(Text("8")),
                            DataCell(Text("80")),
                          ]),
                          DataRow(cells: [
                            DataCell(Text("Report")),
                            DataCell(Text("20")),
                            DataCell(Text("6")),
                            DataCell(Text("102")),

                          ]),
                          DataRow(cells: [
                            DataCell(Text("Test Paper")),
                            DataCell(Text("70")),
                            DataCell(Text("10")),
                            DataCell(Text("90")),

                          ]),
                          DataRow(cells: [
                            DataCell(Text("Worksheet")),
                            DataCell(Text("45")),
                            DataCell(Text("9")),
                            DataCell(Text("34")),
                          ]),
                        ],
                      columnSpacing: 10.0,
                    ),
                  )


                  //CustomPaint(painter: PieChart(3.1415926535/2),),
                  //new logoApp(),

                ],
              ),
            ),
          ),
          Scrollbar(
            child: SingleChildScrollView(
              child:new Container(
                padding: const EdgeInsets.all(16.0),
                child: new Form(
                    child: new Column(
                      children: <Widget>[
                        new Padding(
                          padding: EdgeInsets.all(8.0),
                          child: new Text("Custom Calculation Setting", style: TextStyle(fontSize: 20.0),),
                        ),
                        new TextFormField(
                          decoration: new InputDecoration(
                            labelText: "Total Working Hour",
                            icon: Icon(Icons.av_timer),
                          ),
                        ),
                        new TextFormField(
                          decoration: new InputDecoration(
                            labelText: "Break Periods",
                            icon: Icon(Icons.timelapse),
                          ),
                        ),
                        new TextFormField(
                          decoration: new InputDecoration(
                            labelText: "Other Notice",
                            icon: Icon(Icons.note_add),
                          ),
                        ),
                        new RaisedButton(
                          color: Colors.lightBlue,
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          child: new Text("Save", style: TextStyle(fontSize: 13.0, color: Colors.white),),
                          onPressed: (){
                            setState(() {

                            });
                          }
                        )
                      ],
                    )
                )
                ,
              )
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTap,
        tooltip: 'Increment',
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => new _MyDrawerState();
}
class _MyDrawerState extends State<MyDrawer>{
  GlobalKey<FormState> _form = new GlobalKey<FormState>();
  String name, password;
  TextEditingController t1 = new TextEditingController();
  TextEditingController t2 = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        // DrawerHeader consumes top MediaQuery padding.
        removeTop: true,
        child: Form(
            child: Padding(
                padding: EdgeInsets.only(left: 12.0,top: 38.0, right: 12.0),
              child: new Column(
                children: <Widget>[
                  new Icon(Icons.perm_identity, size: 60.0,),
                  new Text("Login to TimeZipper Account", style: TextStyle(fontSize: 16.0),),
                  new TextFormField(
                    controller: t1,
                    decoration: InputDecoration(
                      labelText: "Username",
                      icon: Icon(Icons.person),
                    ),
                      validator: (v) {
                        return v
                            .trim()
                            .length > 0 ? null : "用户名不能为空";
                      },

                      onSaved: (val){
                      name = val;
                    },
                  ),
                  new TextFormField(
                    controller: t2,
                    decoration: InputDecoration(
                      labelText: "Password",
                      icon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                      validator: (v) {
                        return v
                            .trim()
                            .length > 0 ? null : "密码不为空";
                      },

                      onSaved: (val){
                      password = val;
                    },
                  ),
                  new RaisedButton(
                      color: Colors.lightBlue,
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      child: new Text("Sign in", style: TextStyle(color: Colors.white),),
                      onPressed: (){
                         print(t1.text+" "+t2.text);
                      }
                  )

                ],
              ),
            )
        )
      ),
    );
  }
}

class GradientButton extends StatelessWidget{
  GradientButton({
    this.index,
    this.colors,
    this.width,
    this.height,
    @required this.child,
  });

  final List<Color> colors;
  final double width;
  final double height;
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ThemeData theme = Theme.of(context);
    List<Color> _colors = colors ?? [theme.primaryColor, theme.primaryColorDark ?? theme.primaryColor];

    return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: _colors),
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo,
              offset: Offset(2.5, 2.5),
              blurRadius: 4.0,
            )
          ]
        ),

      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(height: height, width: width),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: DefaultTextStyle(
              style: TextStyle(fontWeight: FontWeight.bold),
              child: child,
            ),
          ),
        ),
      ),
    );

  }
}

class Event{
  String name, category;
  int time;
  double imp;
  TimeOfDay deadline;

  Event(String a, String b, int c, double d, TimeOfDay e){
    this.name = a;
    this.category = b;
    this.time = c;
    this.imp = d;
    this.deadline = e;
  }

  double score(){
    double rawscore = this.time*0.4+this.imp*0.6;
    switch(this.category){
      case "Essay":
        rawscore+=3.0;
        break;
      case "Group Project":
        rawscore+=2.0;
        break;
      case "Worksheet":
        rawscore+=1.0;
        break;
      case "Test Paper":
        rawscore+=4.0;
        break;
      default:
        break;
    }
      return rawscore;
  }
  bool isEarlier(Event e){
    if(this.deadline.hour<e.deadline.hour){
      return true;
    }
    else if(this.deadline.hour==e.deadline.hour){
      if(this.deadline.minute<e.deadline.minute){
        return true;
      }
      else if(this.deadline.minute==e.deadline.minute){
        if(this.score()>e.score()){return true;}
        return false;
      }

    }
    return false;
  }

}
class AnimatePie extends StatefulWidget{
  @override
  _PieState createState() => _PieState();
}
class _PieState extends State<AnimatePie> with SingleTickerProviderStateMixin{
  Animation<double> _animation;
  AnimationController _animationController;
  @override
  void initState(){
    super.initState();
    _animationController = new AnimationController(vsync: this, duration: new Duration(seconds: 3), lowerBound: 0.0,);
    _animation = new CurvedAnimation(parent: _animationController, curve: Curves.easeOutCirc);
    _animation.addListener((){
      this.setState(() {

      });
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new CustomPaint(painter: PieChart(_animation.value),);
  }
  @override
  void dispose(){
    _animationController.dispose();
    super.dispose();
  }
}

class PieChart extends CustomPainter{
  double radian;
  Paint p1 = new Paint();
  Paint p2 = new Paint();
  Paint p3 = new Paint();
  Paint p4 = new Paint();
  PieChart(this.radian){
    p1.color = Colors.lightBlue;
    p1.strokeWidth = 5.0;
    p1.style = PaintingStyle.fill;
    p1.strokeCap = StrokeCap.round;

    p2.color = Colors.redAccent;
    p2.strokeWidth = 5.0;
    p2.style = PaintingStyle.fill;
    p2.strokeCap = StrokeCap.round;

    p3.color = Colors.orange[200];
    p3.strokeWidth = 5.0;
    p3.style = PaintingStyle.fill;
    p3.strokeCap = StrokeCap.round;

    p4.color = Colors.yellow;
    p4.strokeWidth = 5.0;
    p4.style = PaintingStyle.fill;
    p4.strokeCap = StrokeCap.round;
  }
  @override
  void paint(Canvas canvas, Size size){

    Rect rect = new Rect.fromCircle(center: Offset(210.0,100.0), radius: 100.0);
    const double PI = 3.1415926535;
    canvas.drawArc(rect, 0.0, radian*PI/2, true, p1);
    canvas.drawArc(rect, PI/2, PI*radian/3, true, p2);
    canvas.drawArc(rect, 5*PI/6, PI*radian/4, true, p3);
    canvas.drawArc(rect, 13*PI/12, 11*PI*radian/12, true, p4);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate){
    return true;
  }
}
class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SimpleBarChart.withSampleData() {
    return new SimpleBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalData, String>> _createSampleData() {
    final data = [
      new OrdinalData('Essay', 16),
      new OrdinalData('Group Project', 25),
      new OrdinalData('Report', 78),
      new OrdinalData('Test Paper', 58),
    ];

    return [
      new charts.Series<OrdinalData, String>(
        id: 'Learning',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalData sales, _) => sales.category,
        measureFn: (OrdinalData sales, _) => sales.time,
        data: data,
      )
    ];
  }
}
class OrdinalData {
  final String category;
  final int time;

  OrdinalData(this.category, this.time);
}







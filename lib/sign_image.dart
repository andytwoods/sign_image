library sign_image;
import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';


class MarkImageFormField extends FormField<Position> {
  @required
  final Function(Position) onChanged;
  @required
  final List<String> data;
  @required
  final String image;
  final bool enabled;

  MarkImageFormField({
    this.onChanged,
    this.data,
    this.image,
    this.enabled = true,
    FormFieldSetter<Position> onSaved,
    FormFieldValidator<Position> validator,
    Position initialValue,
    bool autovalidate = false,
  }) : super(
      onSaved: onSaved,
      validator: validator,
      initialValue: initialValue,
      autovalidate: autovalidate,
      builder: (FormFieldState<Position> state) {
        return image != null
            ? Container(
          child: Column(
            children: <Widget>[
              Flexible(
                child: MarkImage(
                  enabled: enabled,
                  imageNam: image,
                  initialValue: initialValue,
                  onChanged: (Position p) {
                    if (onChanged != null) {
                      state.didChange(p);
                      onChanged(p);
                    }
                  },
                ),
              ),
              state.hasError && image != null
                  ? Text(state.errorText,
                  style:
                  Theme.of(state.context).textTheme.body2)
                  : Container(),
            ],
          ),
        )
            : Container();
      });
}

class MarkImage extends StatefulWidget {
  @override
  _MarkImageState createState() => new _MarkImageState();
  final String imageNam;
  final Position initialValue;
  final bool enabled;

  final Function(Position p) onChanged;

  MarkImage({this.onChanged, this.imageNam, this.initialValue, this.enabled = true});
}

class _MarkImageState extends State<MarkImage> {
  List<Offset> _points = <Offset>[];
  RectGetter rectGetter;

  @override
  void didUpdateWidget(MarkImage oldWidget) {
    if (oldWidget.imageNam!=null && oldWidget.imageNam != widget.imageNam) {
      setState(() {
        this._points.clear();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    if(widget.initialValue!=null && this._points.length == 0){
      setState(() {
        double x = widget.initialValue.px * widget.initialValue.width * .01;
        double y = widget.initialValue.py * widget.initialValue.height * .01;
        this._points.add(Offset(x, y));
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    CustomPaint customPaint = CustomPaint(
      foregroundPainter: new Signature(points: _points),
      size: Size.infinite,
      child: Image(image: AssetImage(widget.imageNam)),
    );

    rectGetter = new RectGetter.defaultKey(
      child: customPaint,
    );

    return new Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: widget.enabled ? Listener(
            behavior: HitTestBehavior.deferToChild,
            onPointerDown: (PointerDownEvent e) {
              RenderBox referenceBox = context.findRenderObject();
              Offset offset = referenceBox.globalToLocal(e.position);
              setState(() {
                _points = [offset];
                if (widget.onChanged != null) {
                  Rect rect = rectGetter.getRect();
                  double x = offset.dx / rect.width * 100;
                  double y = offset.dy / rect.height * 100;
                  Position p = Position(x, y, rect.width, rect.height);
                  widget.onChanged(p);
                }
              });
            },
            child: rectGetter,
          ): customPaint,
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.red,
        child: new Icon(Icons.clear),
        onPressed: () {
          _points.clear();
          if (widget.onChanged != null) {
            widget.onChanged(null);
          }
        },
      ),
    );
  }
}

class Signature extends CustomPainter {
  List<Offset> points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {

    Paint paint = new Paint()..color = Colors.blue;

    points.forEach((Offset p) {
      canvas.drawCircle(p, 20.0, paint);
    });
  }

  @override
  bool shouldRepaint(Signature oldDelegate) {
    return oldDelegate.points != points;
  }
}

class Position{
  final double px;
  final double py;
  final double width;
  final double height;

  Position(this.px, this.py, this.width, this.height);
}
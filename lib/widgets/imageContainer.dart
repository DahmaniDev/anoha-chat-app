import 'package:flutter/material.dart';
import 'package:kelemni/widgets/fullPhoto.dart';
import 'package:kelemni/widgets/loading.dart';



Widget imageContainer(BuildContext ctx, String imgUrl) {
  return GestureDetector(
    onTap: (){
      Navigator.push(
          ctx, MaterialPageRoute(builder: (context) => FullPhoto(url: imgUrl)));
    },
    child: Container(
      child: Material(
        child: Image.network(
          imgUrl,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              child: Center(
                child: Loading(),
              ),
            );
          },
          errorBuilder: (context, object, stackTrace) {
            return Material(
              child: Image.asset(
                'assets/img_not_available.jpeg',
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(14.0),
              ),
              clipBehavior: Clip.hardEdge,
            );
          },
          width: MediaQuery.of(ctx).size.width * 0.5,
          height: MediaQuery.of(ctx).size.width * 0.5,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        clipBehavior: Clip.hardEdge,
      ),
      margin: EdgeInsets.only(bottom: 10.0, right: 10.0, left: 10.0),
    ),
  );
}
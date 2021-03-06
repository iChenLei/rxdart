import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

Stream<int> _getStream() => new Stream.fromIterable(const [0, 1, 2, 3]);

const List<int> expected = [0, 1, 2, 3];

void main() {
  test('rx.Observable.onErrorResumeNext', () async {
    var count = 0;

    new Observable(new ErrorStream<num>(new Exception()))
        .onErrorResumeNext(_getStream())
        .listen(expectAsync1((result) {
          expect(result, expected[count++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResumeNext.reusable', () async {
    // ignore: deprecated_member_use
    final transformer =
        // ignore: deprecated_member_use
        new OnErrorResumeNextStreamTransformer(
            _getStream().asBroadcastStream());
    var countA = 0, countB = 0;

    new Observable(new ErrorStream<int>(new Exception()))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expected[countA++]);
        }, count: expected.length));

    new Observable(new ErrorStream<int>(new Exception()))
        .transform(transformer)
        .listen(expectAsync1((result) {
          expect(result, expected[countB++]);
        }, count: expected.length));
  });

  test('rx.Observable.onErrorResumeNext.asBroadcastStream', () async {
    final stream = new Observable(new ErrorStream<int>(new Exception()))
        .onErrorResumeNext(_getStream())
        .asBroadcastStream();
    var countA = 0, countB = 0;

    await expectLater(stream.isBroadcast, isTrue);

    stream.listen(expectAsync1((result) {
      expect(result, expected[countA++]);
    }, count: expected.length));
    stream.listen(expectAsync1((result) {
      expect(result, expected[countB++]);
    }, count: expected.length));
  });

  test('rx.Observable.onErrorResumeNext.error.shouldThrow', () async {
    final observableWithError =
        new Observable(new ErrorStream<void>(new Exception()))
            .onErrorResumeNext(new ErrorStream<void>(new Exception()));

    observableWithError.listen(null,
        onError: expectAsync2((Exception e, StackTrace s) {
      expect(e, isException);
    }));
  });

  test('rx.Observable.onErrorResumeNext.pause.resume', () async {
    StreamSubscription<num> subscription;
    var count = 0;

    subscription = new Observable(new ErrorStream<int>(new Exception()))
        .onErrorResumeNext(_getStream())
        .listen(expectAsync1((result) {
          expect(result, expected[count++]);

          if (count == expected.length) {
            subscription.cancel();
          }
        }, count: expected.length));

    subscription.pause();
    subscription.resume();
  });

  test('rx.Observable.onErrorResumeNext.close', () async {
    var count = 0;

    new Observable(new ErrorStream<int>(new Exception()))
        .onErrorResumeNext(_getStream())
        .listen(
            expectAsync1((result) {
              expect(result, expected[count++]);
            }, count: expected.length),
            onDone: expectAsync0(() {
              // The code should reach this point
              expect(true, true);
            }, count: 1));
  });
}

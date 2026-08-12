abstract final class SfuEvents {
  static const String joinRoom = 'sfu:join-room';

  static const String waitingUpdate =
      'sfu:waiting-update';

  static const String hostJoined =
      'sfu:host-joined';

  static const String participantUpdate =
      'sfu:participant-update';

  static const String createTransport =
      'sfu:create-transport';

  static const String connectTransport =
      'sfu:connect-transport';

  static const String produce =
      'sfu:produce';

  static const String listProducers =
      'sfu:list-producers';

  static const String consume =
      'sfu:consume';

  static const String resumeConsumer =
      'sfu:resume-consumer';

  static const String sendChatMessage =
      'sfu:send-message';

  static const String chatMessage =
      'sfu:new-message';

  static const String toggleMute =
      'sfu:toggle-mute';

  static const String toggleVideo =
      'sfu:toggle-video';

  static const String participantMutedStatus =
      'sfu:participant-muted-status';

  static const String participantVideoStatus =
      'sfu:participant-video-status';

  static const String closeProducer =
      'sfu:close-producer';

  static const String newProducer =
      'sfu:new-producer';

  static const String producerClosed =
      'sfu:producer-closed';
}

enum ClockFrameStyle {
  circle('Circle'),
  square('Square'),
  none('None');

  final String label;
  const ClockFrameStyle(this.label);
}

enum ClockHandStyle {
  standard('Standard'),
  elegant('Elegant'),
  arrow('Arrow');

  final String label;
  const ClockHandStyle(this.label);
}

enum MinuteMarkerStyle {
  none('None'),
  fivesOnly('Fives Only'),
  allWithHighlight('All with Highlight');

  final String label;
  const MinuteMarkerStyle(this.label);
}

enum ClockDisplayMode {
  analog('Analog Only'),
  digital('Digital Only'),
  both('Both Clocks');

  final String label;
  const ClockDisplayMode(this.label);
}

enum TimeFormat {
  hour12('12-hour'),
  hour24('24-hour');

  final String label;
  const TimeFormat(this.label);
}

enum DigitalEffects {
  none('None'),
  neon('Neon'),
  lcd('LCD'),
  matrix('Matrix'),
  glowPulse('Glow Pulse');

  final String name;
  const DigitalEffects(this.name);
}
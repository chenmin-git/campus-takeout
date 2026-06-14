import React from 'react';
import {
  AbsoluteFill,
  Easing,
  Img,
  Sequence,
  interpolate,
  staticFile,
  useCurrentFrame,
  useVideoConfig
} from 'remotion';

type Scene = {
  id: string;
  index: number;
  title: string;
  subtitle: string;
  image?: string;
  bullets?: string[];
  startMs: number;
  endMs: number;
  accent: string;
  kind?: 'diagram' | 'image';
};

type DemoVideoProps = {
  scenes: Scene[];
};

const colors = {
  bg: '#111827',
  ink: '#f8fafc',
  muted: '#cbd5e1',
  orange: '#ff6b35',
  green: '#22c55e',
  blue: '#38bdf8',
  panel: 'rgba(15, 23, 42, 0.82)'
};

const accentColor = (accent: string) => {
  if (accent.includes('AI')) return colors.orange;
  if (accent.includes('商家')) return colors.green;
  if (accent.includes('骑手')) return colors.blue;
  if (accent.includes('管理员')) return '#a78bfa';
  return '#f59e0b';
};

const DiagramScene: React.FC<{ scene: Scene; sceneFrames: number; total: number }> = ({
  scene,
  sceneFrames,
  total
}) => {
  const frame = useCurrentFrame();
  const enter = interpolate(frame, [0, 8], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.bezier(0.16, 1, 0.3, 1)
  });
  const progress = interpolate(frame, [0, sceneFrames], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp'
  });
  const color = accentColor(scene.accent);
  const bullets = scene.bullets || [];

  return (
    <AbsoluteFill style={{ backgroundColor: colors.bg, color: colors.ink }}>
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background:
            'linear-gradient(155deg, rgba(255,107,53,0.18) 0%, rgba(17,24,39,0.92) 38%, rgba(15,23,42,1) 100%)'
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 62,
          right: 62,
          top: 56,
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          opacity: enter
        }}
      >
        <div style={{ fontSize: 34, fontWeight: 900 }}>校园外卖 H5</div>
        <div style={{ fontSize: 24, color: colors.muted }}>{scene.index}/{total}</div>
      </div>

      <div
        style={{
          position: 'absolute',
          left: 72,
          right: 72,
          top: 188,
          opacity: enter,
          transform: `translateY(${(1 - enter) * 24}px)`
        }}
      >
        <div
          style={{
            display: 'inline-block',
            padding: '10px 18px',
            borderRadius: 999,
            backgroundColor: 'rgba(255,255,255,0.1)',
            color,
            fontSize: 24,
            fontWeight: 800,
            marginBottom: 22
          }}
        >
          {scene.accent}
        </div>
        <div style={{ fontSize: 58, lineHeight: 1.16, fontWeight: 900 }}>{scene.title}</div>
        <div style={{ marginTop: 24, fontSize: 30, lineHeight: 1.48, color: colors.muted }}>
          {scene.subtitle}
        </div>
      </div>

      <div
        style={{
          position: 'absolute',
          left: 72,
          right: 72,
          top: 620,
          display: 'grid',
          gap: 24,
          opacity: enter
        }}
      >
        {bullets.map((b, i) => {
          const itemEnter = interpolate(frame, [6 + i * 5, 18 + i * 5], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp'
          });
          return (
            <div
              key={b}
              style={{
                display: 'flex',
                gap: 18,
                padding: '24px 26px',
                borderRadius: 24,
                backgroundColor: 'rgba(255,255,255,0.08)',
                border: '1px solid rgba(255,255,255,0.14)',
                opacity: itemEnter,
                transform: `translateX(${(1 - itemEnter) * 30}px)`
              }}
            >
              <div
                style={{
                  width: 34,
                  height: 34,
                  borderRadius: 999,
                  backgroundColor: color,
                  flex: '0 0 auto',
                  marginTop: 3
                }}
              />
              <div style={{ fontSize: 31, lineHeight: 1.38, fontWeight: 700 }}>{b}</div>
            </div>
          );
        })}
      </div>

      <div
        style={{
          position: 'absolute',
          left: 72,
          right: 72,
          bottom: 96,
          height: 9,
          borderRadius: 999,
          backgroundColor: 'rgba(255,255,255,0.14)',
          overflow: 'hidden',
          opacity: enter
        }}
      >
        <div style={{ height: '100%', width: `${Math.max(2, progress * 100)}%`, backgroundColor: color }} />
      </div>
    </AbsoluteFill>
  );
};

const SceneFrame: React.FC<{ scene: Scene; sceneFrames: number; total: number }> = ({
  scene,
  sceneFrames,
  total
}) => {
  const frame = useCurrentFrame();
  const enter = interpolate(frame, [0, 6], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.bezier(0.16, 1, 0.3, 1)
  });
  const exit = interpolate(frame, [sceneFrames - 14, sceneFrames], [1, 0.96], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp'
  });
  const scale = interpolate(frame, [0, sceneFrames], [1, 1.018], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp'
  });
  const progress = interpolate(frame, [0, sceneFrames], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp'
  });
  const color = accentColor(scene.accent);

  return (
    <AbsoluteFill style={{ backgroundColor: colors.bg }}>
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background:
            'linear-gradient(180deg, rgba(17,24,39,0.55) 0%, rgba(17,24,39,0.1) 18%, rgba(17,24,39,0.08) 68%, rgba(17,24,39,0.78) 100%)'
        }}
      />
      <div
        style={{
          position: 'absolute',
          left: 52,
          right: 52,
          top: 124,
          bottom: 274,
          borderRadius: 28,
          overflow: 'hidden',
          backgroundColor: '#ffffff',
          boxShadow: '0 36px 110px rgba(0,0,0,0.46)',
          opacity: enter,
          transform: `translateY(${(1 - enter) * 28}px) scale(${scale * exit})`
        }}
      >
        {scene.image ? (
          <Img
            src={staticFile(scene.image)}
            style={{
              width: '100%',
              height: '100%',
              objectFit: 'contain',
              backgroundColor: '#ffffff'
            }}
          />
        ) : null}
      </div>

      <div
        style={{
          position: 'absolute',
          left: 56,
          right: 56,
          top: 42,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          color: colors.ink,
          opacity: enter
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <div
            style={{
              width: 16,
              height: 16,
              borderRadius: 999,
              backgroundColor: color
            }}
          />
          <div style={{ fontSize: 32, fontWeight: 800 }}>校园外卖 H5</div>
        </div>
        <div
          style={{
            padding: '10px 18px',
            borderRadius: 999,
            backgroundColor: 'rgba(255,255,255,0.1)',
            fontSize: 24,
            color: colors.muted
          }}
        >
          {scene.index}/{total}
        </div>
      </div>

      <div
        style={{
          position: 'absolute',
          left: 64,
          right: 64,
          bottom: 86,
          padding: '28px 32px 30px',
          borderRadius: 26,
          backgroundColor: colors.panel,
          border: `2px solid ${color}`,
          color: colors.ink,
          opacity: enter,
          transform: `translateY(${(1 - enter) * 22}px)`
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: 20,
            marginBottom: 14
          }}
        >
          <div style={{ fontSize: 31, fontWeight: 800, lineHeight: 1.24 }}>{scene.title}</div>
          <div
            style={{
              flex: '0 0 auto',
              padding: '8px 14px',
              borderRadius: 999,
              color,
              backgroundColor: 'rgba(255,255,255,0.08)',
              fontSize: 20,
              fontWeight: 700
            }}
          >
            {scene.accent}
          </div>
        </div>
        <div style={{ fontSize: 25, lineHeight: 1.48, color: colors.muted }}>{scene.subtitle}</div>
        <div
          style={{
            marginTop: 22,
            height: 8,
            width: '100%',
            borderRadius: 99,
            backgroundColor: 'rgba(255,255,255,0.14)',
            overflow: 'hidden'
          }}
        >
          <div
            style={{
              height: '100%',
              width: `${Math.max(2, progress * 100)}%`,
              backgroundColor: color,
              borderRadius: 99
            }}
          />
        </div>
      </div>
    </AbsoluteFill>
  );
};

export const DemoVideo: React.FC<DemoVideoProps> = ({ scenes }) => {
  const { fps } = useVideoConfig();
  const sceneFrames = Math.round((120 / scenes.length) * fps);
  return (
    <AbsoluteFill style={{ backgroundColor: colors.bg }}>
      {scenes.map((scene, index) => (
        <Sequence key={scene.id} from={index * sceneFrames} durationInFrames={sceneFrames}>
          {scene.kind === 'diagram' ? (
            <DiagramScene scene={scene} sceneFrames={sceneFrames} total={scenes.length} />
          ) : (
            <SceneFrame scene={scene} sceneFrames={sceneFrames} total={scenes.length} />
          )}
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};

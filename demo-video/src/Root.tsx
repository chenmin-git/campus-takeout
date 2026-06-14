import { Composition } from 'remotion';
import { DemoVideo } from './Video';
import scenes from '../public/full-demo-scenes.json';

const fps = 30;
const durationInFrames = Math.round(120 * fps);

export const RemotionRoot = () => {
  return (
    <Composition
      id="CampusTakeoutH5AiDemo"
      component={DemoVideo}
      durationInFrames={durationInFrames}
      fps={fps}
      width={1080}
      height={1920}
      defaultProps={{ scenes }}
    />
  );
};

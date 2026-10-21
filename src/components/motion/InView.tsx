// InView from Motion Primitives (https://motion-primitives.com/docs/in-view):
// animates its children from `hidden` to `visible` when they scroll into view.
import { useRef, useState, type ReactNode } from 'react';
import { motion, MotionConfig, useInView, type Transition, type UseInViewOptions, type Variant } from 'motion/react';

export interface InViewProps {
  children: ReactNode;
  variants?: { hidden: Variant; visible: Variant };
  transition?: Transition;
  viewOptions?: UseInViewOptions;
  as?: 'div' | 'section' | 'li' | 'ul' | 'ol' | 'article' | 'span';
  once?: boolean;
  className?: string;
}

const defaultVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
};

export function InView({
  children,
  variants = defaultVariants,
  transition,
  viewOptions,
  as = 'div',
  once,
  className,
}: InViewProps) {
  const ref = useRef(null);
  const isInView = useInView(ref, viewOptions);
  const [isViewed, setIsViewed] = useState(false);
  const MotionComponent = motion[as] as typeof motion.div;

  return (
    // Visitors who ask for reduced motion get the fade without movement.
    <MotionConfig reducedMotion="user">
      <MotionComponent
        ref={ref}
        className={className}
        initial="hidden"
        onAnimationComplete={() => {
          if (once && isInView) setIsViewed(true);
        }}
        animate={isInView || isViewed ? 'visible' : 'hidden'}
        variants={variants}
        transition={transition}
      >
        {children}
      </MotionComponent>
    </MotionConfig>
  );
}

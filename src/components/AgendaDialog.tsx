import { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { animate, useReducedMotion } from 'motion/react';

/**
 * Inline "see this diagram" link that opens the research-agenda diagram in a
 * modal. The dialog is portaled to <body> because it can't live inside a <p>.
 */
export default function AgendaDialog() {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);
  // Fade without scaling for visitors who ask for reduced motion.
  const reduceMotion = useReducedMotion();
  const closing = useRef(false);

  const open = () => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    dialog.showModal();
    animate(dialog, reduceMotion ? { opacity: [0, 1] } : { opacity: [0, 1], scale: [0.96, 1] }, { duration: 0.2, ease: 'easeOut' });
  };

  // Play the exit animation, then close for real (which also returns focus to the link).
  const close = async () => {
    const dialog = dialogRef.current;
    if (!dialog || closing.current) return;
    closing.current = true;
    await animate(dialog, reduceMotion ? { opacity: 0 } : { opacity: 0, scale: 0.96 }, { duration: 0.15, ease: 'easeIn' });
    dialog.close();
    closing.current = false;
  };

  return (
    <>
      <a
        href="#research-agenda"
        className="agenda-open"
        onClick={(e) => {
          e.preventDefault();
          open();
        }}
      >
        see this diagram <i className="bi bi-diagram-3" aria-hidden="true" />
      </a>
      {mounted &&
        createPortal(
          <dialog
            ref={dialogRef}
            id="research-agenda"
            className="agenda-dialog"
            aria-labelledby="agenda-diagram-caption"
            onClick={(e) => e.target === dialogRef.current && close()}
            onCancel={(e) => {
              // Escape: animate out instead of closing instantly.
              e.preventDefault();
              close();
            }}
          >
            <button type="button" className="dialog-close" aria-label="Close" onClick={close}>
              &times;
            </button>
            <figure className="agenda-diagram">
              <figcaption id="agenda-diagram-caption" className="agenda-caption">
                Two connected consequences of legalistic governance
              </figcaption>
              <div className="agenda-source">
                <span>The U.S. response to economic, social, and political complexity</span>
                <strong>Legalistic mode of governance</strong>
              </div>
              <div className="agenda-branches">
                <Branch
                  className="agenda-citizens"
                  relation="Government → Citizens"
                  steps={['Heavier administrative burdens on people', 'Difficulty accessing government programs']}
                  program="Reduce administrative burdens and strengthen public trust"
                />
                <Branch
                  className="agenda-business"
                  relation="Government → Business"
                  steps={['Resource constraints on government', 'Dependence on private contractors']}
                  program="Improve tech (AI) procurement and contractor management"
                />
              </div>
            </figure>
          </dialog>,
          document.body,
        )}
    </>
  );
}

function Branch({ className, relation, steps, program }: { className: string; relation: string; steps: [string, string]; program: string }) {
  return (
    <div className={`agenda-branch ${className}`}>
      <div className="agenda-relation">{relation}</div>
      <div className="agenda-step">
        <strong>{steps[0]}</strong>
      </div>
      <div className="agenda-arrow" aria-hidden="true" />
      <div className="agenda-step agenda-outcome">
        <strong>{steps[1]}</strong>
      </div>
      <div className="agenda-arrow" aria-hidden="true" />
      <div className="agenda-program">
        <small>Research program</small>
        <strong>{program}</strong>
      </div>
    </div>
  );
}

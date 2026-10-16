import { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';

/**
 * Inline "see this diagram" link that opens the research-agenda diagram in a
 * modal. The dialog is portaled to <body> because it can't live inside a <p>.
 */
export default function AgendaDialog() {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  const close = () => dialogRef.current?.close();

  return (
    <>
      <a
        href="#research-agenda"
        className="agenda-open"
        onClick={(e) => {
          e.preventDefault();
          dialogRef.current?.showModal();
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

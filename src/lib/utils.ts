import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

/** Join class names, letting later Tailwind classes override earlier ones (used by Motion Primitives). */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

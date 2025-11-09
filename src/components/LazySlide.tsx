import { Suspense, ReactNode } from 'react';
import { Skeleton } from '@/components/ui/skeleton';

interface LazySlideSuspenseProps {
  children: ReactNode;
}

const SlideSkeleton = () => (
  <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-background via-secondary/5 to-primary/10">
    <div className="space-y-4 w-full max-w-7xl px-6">
      <Skeleton className="h-16 w-3/4 mx-auto" />
      <Skeleton className="h-96 w-full" />
      <div className="grid grid-cols-2 gap-4">
        <Skeleton className="h-40" />
        <Skeleton className="h-40" />
      </div>
    </div>
  </div>
);

export function LazySlide({ children }: LazySlideSuspenseProps) {
  return <Suspense fallback={<SlideSkeleton />}>{children}</Suspense>;
}

import { Injectable, inject } from '@angular/core';
import {
  HttpEvent,
  HttpHandler,
  HttpInterceptor,
  HttpRequest,
} from '@angular/common/http';
import { Auth } from '@angular/fire/auth';
import { Observable, from, switchMap } from 'rxjs';
import { environment } from '../../environments/environments';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  private auth: Auth = inject(Auth);

  intercept(
    req: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    if (!environment.apiUrl || !req.url.startsWith(environment.apiUrl)) {
      return next.handle(req);
    }

    const currentUser = this.auth.currentUser;
    if (!currentUser) {
      return next.handle(req);
    }

    return from(currentUser.getIdToken()).pipe(
      switchMap((token) => {
        const authReq = req.clone({
          setHeaders: {
            Authorization: `Bearer ${token}`,
          },
        });
        return next.handle(authReq);
      })
    );
  }
}

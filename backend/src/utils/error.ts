class ApiError extends Error {
  constructor(message: string, public statusCode: number) {
    super(message);
  }
}

class BadRequestError extends ApiError {
  constructor(message: string) {
    super(message, 400);
  }
}

class UnauthorizedError extends ApiError {
  constructor(message: string) {
    super(message, 401);
  }
}

class ForbiddenError extends ApiError {
  constructor(message: string) {
    super(message, 403);
  }
}

class NotFoundError extends ApiError {
  constructor(message: string) {
    super(message, 404);
  }
}

class MethodNotAllowedError extends ApiError {
  constructor(message: string) {
    super(message, 405);
  }
}

class RequestTimeoutError extends ApiError {
  constructor(message: string) {
    super(message, 408);
  }
}

class ConflictError extends ApiError {
  constructor(message: string) {
    super(message, 409);
  }
}

class InternalServerError extends ApiError {
  constructor(message: string) {
    super(message, 500);
  }
}

export { ApiError, BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, ConflictError, InternalServerError, MethodNotAllowedError, RequestTimeoutError };
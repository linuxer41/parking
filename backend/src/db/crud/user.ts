
import { BaseCrud } from './base-crud';
import { User, UserCreate, UserUpdate } from '../../models/user';

class UserCrud extends BaseCrud<User, UserCreate, UserUpdate> {
  constructor() {
    super('t_user');
  }

  baseQuery() {
    return `
select t_user.* 
from t_user

`;
  }
}

export const userCrud = new UserCrud()

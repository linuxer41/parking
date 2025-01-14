
import '_base_service.dart';
import '../models/company_model.dart';

class CompanyService extends BaseService<CompanyModel, CompanyCreateModel, CompanyUpdateModel> {
  CompanyService() : super(path: '/company', fromJsonFactory: CompanyModel.fromJson);
}

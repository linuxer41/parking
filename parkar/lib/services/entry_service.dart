
import '_base_service.dart';
import '../models/entry_model.dart';

class EntryService extends BaseService<EntryModel, EntryCreateModel, EntryUpdateModel> {
  EntryService() : super(path: '/entry', fromJsonFactory: EntryModel.fromJson);
}

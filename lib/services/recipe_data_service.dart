import '../models/recipe.dart';

class RecipeDataService {
  static final RecipeDataService instance = RecipeDataService._internal();

  RecipeDataService._internal() {
    _initData();
  }

  final List<Recipe> _recipes = [];
  final List<RecipeCollection> _collections = [];
  final List<ShoppingItem> _shoppingList = [];

  List<Recipe> get allRecipes => List.unmodifiable(_recipes);
  List<Recipe> get favoriteRecipes =>
      _recipes.where((r) => r.isFavorite).toList();
  List<Recipe> get historyRecipes =>
      _recipes.where((r) => r.lastViewedAt != null).toList()
        ..sort((a, b) => b.lastViewedAt!.compareTo(a.lastViewedAt!));
  List<Recipe> get cookedRecipes =>
      _recipes.where((r) => r.cookedCount > 0).toList()
        ..sort((a, b) => b.cookedCount.compareTo(a.cookedCount));
  List<RecipeCollection> get collections => List.unmodifiable(_collections);
  List<ShoppingItem> get shoppingList => List.unmodifiable(_shoppingList);

  void toggleFavorite(String recipeId) {
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _recipes[index] = _recipes[index].copyWith(
        isFavorite: !_recipes[index].isFavorite,
      );
    }
  }

  void updateRecipe(Recipe updated) {
    final index = _recipes.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _recipes[index] = updated;
    }
  }

  void markAsCooked(String recipeId) {
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _recipes[index] = _recipes[index].copyWith(
        cookedCount: _recipes[index].cookedCount + 1,
        lastViewedAt: DateTime.now(),
      );
    }
  }

  void addCollection(RecipeCollection collection) {
    _collections.add(collection);
  }

  void addShoppingItems(List<ShoppingItem> items) {
    _shoppingList.addAll(items);
  }

  void addShoppingItem(ShoppingItem item) {
    _shoppingList.add(item);
  }

  void toggleShoppingItem(String id) {
    final index = _shoppingList.indexWhere((item) => item.id == id);
    if (index != -1) {
      _shoppingList[index].isCompleted = !_shoppingList[index].isCompleted;
    }
  }

  void removeShoppingItem(String id) {
    _shoppingList.removeWhere((item) => item.id == id);
  }

  void clearCompletedShoppingItems() {
    _shoppingList.removeWhere((item) => item.isCompleted);
  }

  void _initData() {
    _recipes.addAll([
      Recipe(
        id: 'rec_1',
        title: 'Phở Bò Tái Lăn Hà Nội Chuẩn Vị',
        category: 'Món nước',
        imageUrl:
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=800&auto=format&fit=crop&q=80',
        chefName: 'Chef Hoàng Nam',
        chefAvatar: '',
        rating: 4.9,
        reviewsCount: 384,
        cookTimeMinutes: 45,
        difficulty: 'Trung bình',
        calories: 520,
        servings: 4,
        tags: ['#TruyềnThống', '#PhởBò', '#HàNội', '#MónNước'],
        isFavorite: true,
        isSaved: true,
        cookedCount: 3,
        lastViewedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ingredients: [
          Ingredient(id: 'i1', name: 'Bánh phở tươi', amount: '500g'),
          Ingredient(id: 'i2', name: 'Thịt bò phi lê', amount: '350g'),
          Ingredient(
            id: 'i3',
            name: 'Xương ống bò hầm nước dùng',
            amount: '1kg',
          ),
          Ingredient(
            id: 'i4',
            name: 'Hành hoa, rau mùi, húng quế',
            amount: '100g',
          ),
          Ingredient(
            id: 'i5',
            name: 'Hoa hồi, quế, thảo quả nướng',
            amount: '1 gói',
          ),
          Ingredient(id: 'i6', name: 'Gừng nướng & hành khô', amount: '50g'),
          Ingredient(
            id: 'i7',
            name: 'Nước mắm cá cơm truyền thống',
            amount: '3 muỗng canh',
          ),
        ],
        steps: [
          const CookingStep(
            stepNumber: 1,
            title: 'Hầm nước dùng bò thanh ngọt',
            description:
                'Trần sơ xương bò với nước sôi và gừng. Hầm xương lửa nhỏ trong 4-6 tiếng cùng hoa hồi, quế, thảo quả đã rang thơm.',
            tip: 'Thường xuyên hớt bọt để nước dùng trong vắt và thơm thanh.',
            durationMinutes: 30,
          ),
          const CookingStep(
            stepNumber: 2,
            title: 'Thái lát và xào lăn thịt bò',
            description:
                'Thái thịt bò mỏng ngang thớ. Đun chảo thật nóng, phi thơm tỏi băm và gừng rồi trút thịt bò vào đảo nhanh tay trong 1 phút.',
            tip: 'Xào lửa cực lớn để thịt bò giữ độ mềm ngọt, không bị dai.',
            durationMinutes: 5,
          ),
          const CookingStep(
            stepNumber: 3,
            title: 'Trần bánh phở & Trình bày',
            description:
                'Trần bánh phở qua nước sôi, xếp vào bát tô, múc thịt bò xào lăn lên trên cùng hành hoa, chan nước dùng sôi sùng sục và thưởng thức.',
            tip: 'Dùng kèm chanh ớt tươi và quẩy giòn.',
            durationMinutes: 10,
          ),
        ],
      ),
      Recipe(
        id: 'rec_2',
        title: 'Salad Ức Gà Áp Chảo Sốt Mè Rang',
        category: 'Eat Clean',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
        chefName: 'Linh Đan Healthy',
        chefAvatar: '',
        rating: 4.8,
        reviewsCount: 215,
        cookTimeMinutes: 15,
        difficulty: 'Dễ',
        calories: 320,
        servings: 2,
        tags: ['#EatClean', '#GiảmCân', '#Healthy', '#ỨcGà'],
        isFavorite: true,
        isSaved: true,
        cookedCount: 6,
        lastViewedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ingredients: [
          Ingredient(id: 'i21', name: 'Ức gà phi lê không da', amount: '250g'),
          Ingredient(
            id: 'i22',
            name: 'Xà lách Romaine & bắp cải tím',
            amount: '150g',
          ),
          Ingredient(
            id: 'i23',
            name: 'Cà chua bi & dưa chuột baby',
            amount: '100g',
          ),
          Ingredient(
            id: 'i24',
            name: 'Sốt mè rang Kewpie',
            amount: '3 muỗng canh',
          ),
          Ingredient(
            id: 'i25',
            name: 'Dầu ô liu, muối hồng, tiêu đen',
            amount: '1 thìa cafe',
          ),
          Ingredient(
            id: 'i26',
            name: 'Trứng gà luộc lòng đào',
            amount: '1 quả',
          ),
        ],
        steps: [
          const CookingStep(
            stepNumber: 1,
            title: 'Sơ chế & ướp ức gà',
            description:
                'Rửa sạch ức gà, khía nhẹ mặt thịt. Ướp cùng một chút muối hồng, tiêu xay và dầu ô liu trong 10 phút.',
            tip: 'Khía mắt lưới giúp gia vị ngấm đều và gà chín nhanh.',
            durationMinutes: 5,
          ),
          const CookingStep(
            stepNumber: 2,
            title: 'Áp chảo ức gà vàng mọng nước',
            description:
                'Làm nóng chảo chống dính với 1 thìa dầu ô liu. Áp chảo mỗi mặt 4-5 phút trên lửa vừa đến khi vàng đều.',
            tip:
                'Đậy nắp chảo khi áp chảo để ức gà chín đều mọng nước không bị khô.',
            durationMinutes: 8,
          ),
          const CookingStep(
            stepNumber: 3,
            title: 'Trộn rau & Rưới sốt mè rang',
            description:
                'Cắt ức gà thành miếng vừa ăn. Xếp rau củ ra đĩa, đặt gà và trứng lòng đào lên trên, rưới sốt mè rang và thưởng thức.',
            durationMinutes: 2,
          ),
        ],
      ),
      Recipe(
        id: 'rec_3',
        title: 'Bò Sốt Tiêu Đen Kèm Bánh Mì Giòn',
        category: 'Món chính',
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
        chefName: 'Gordon Hải',
        chefAvatar: '',
        rating: 4.9,
        reviewsCount: 198,
        cookTimeMinutes: 25,
        difficulty: 'Trung bình',
        calories: 610,
        servings: 3,
        tags: ['#BòSốtTiêu', '#BánhMì', '#ĐậmĐà', '#MónChính'],
        isFavorite: true,
        isSaved: true,
        cookedCount: 2,
        lastViewedAt: DateTime.now().subtract(const Duration(days: 1)),
        ingredients: [
          Ingredient(id: 'i31', name: 'Thịt thăn bò tươi', amount: '400g'),
          Ingredient(id: 'i32', name: 'Ớt chuông xanh đỏ', amount: '1 quả'),
          Ingredient(id: 'i33', name: 'Hành tây trắng', amount: '1 củ'),
          Ingredient(
            id: 'i34',
            name: 'Tiêu đen xay vỡ',
            amount: '2 muỗng cafe',
          ),
          Ingredient(
            id: 'i35',
            name: 'Dầu hào, bơ lạt, tỏi băm',
            amount: '2 muỗng',
          ),
          Ingredient(
            id: 'i36',
            name: 'Bột năng pha loãng tạo sốt',
            amount: '1 muỗng cafe',
          ),
        ],
        steps: [
          const CookingStep(
            stepNumber: 1,
            title: 'Cắt và ướp thịt bò',
            description:
                'Cắt thịt bò khối quân cờ. Ướp dầu hào, tiêu đen, tỏi băm và một chút xì dầu trong 15 phút.',
            durationMinutes: 10,
          ),
          const CookingStep(
            stepNumber: 2,
            title: 'Nấu sốt tiêu đen sánh quyện',
            description:
                'Phi thơm bơ với tỏi, cho ớt chuông hành tây xào săn rồi cho thịt bò vào đảo lửa lớn. Cho nước sốt tiêu đen và bột bắp tạo độ sánh mịn.',
            tip: 'Không xào thịt bò quá lâu để giữ độ mềm ngọt tự nhiên.',
            durationMinutes: 10,
          ),
          const CookingStep(
            stepNumber: 3,
            title: 'Hoàn thành món ăn',
            description:
                'Múc bò sốt tiêu đen ra đĩa sâu lòng, rắc thêm tiêu đập dập. Ăn kèm bánh mì nóng giòn rụm.',
            durationMinutes: 5,
          ),
        ],
      ),
      Recipe(
        id: 'rec_4',
        title: 'Bún Chả Nướng Than Hoa Hà Nội',
        category: 'Món chính',
        imageUrl:
            'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=800&auto=format&fit=crop&q=80',
        chefName: 'Bà Bảy Bún Chả',
        chefAvatar: '',
        rating: 4.9,
        reviewsCount: 512,
        cookTimeMinutes: 40,
        difficulty: 'Khó',
        calories: 580,
        servings: 4,
        tags: ['#BúnChả', '#ĐặcSản', '#HàNội', '#NướngThan'],
        isFavorite: true,
        isSaved: true,
        cookedCount: 4,
        lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
        ingredients: [
          Ingredient(id: 'i41', name: 'Thịt ba chỉ rút sườn', amount: '400g'),
          Ingredient(id: 'i42', name: 'Thịt nạc vai xay', amount: '350g'),
          Ingredient(id: 'i43', name: 'Bún tươi sợi nhỏ', amount: '800g'),
          Ingredient(
            id: 'i44',
            name: 'Đu đủ xanh & cà rốt giòn',
            amount: '1 củ',
          ),
          Ingredient(
            id: 'i45',
            name: 'Nước mắm, đường nâu, giấm, tỏi ớt',
            amount: 'Vừa đủ',
          ),
          Ingredient(
            id: 'i46',
            name: 'Rau sống: tía tô, kinh giới, xà lách',
            amount: '200g',
          ),
        ],
        steps: [
          const CookingStep(
            stepNumber: 1,
            title: 'Ướp thịt miếng & thịt viên',
            description:
                'Ướp thịt cùng nước mắm cốt, nước hàng đường mía, hành khô, tiêu xay trong ít nhất 30 phút.',
            tip:
                'Nước hàng tự thắng bằng đường mía cho màu chả vàng cánh gián óng ả.',
            durationMinutes: 15,
          ),
          const CookingStep(
            stepNumber: 2,
            title: 'Nướng chả trên than hồng',
            description:
                'Kẹp thịt vào vỉ nướng trên than hoa đỏ rực, lật đều tay đến khi chả cháy xém cạnh và thơm nức mũi.',
            durationMinutes: 15,
          ),
          const CookingStep(
            stepNumber: 3,
            title: 'Pha nước chấm chua ngọt & Ăn kèm',
            description:
                'Pha nước mắm ấm chua ngọt theo tỷ lệ vàng (1 mắm : 1 đường : 1 giấm : 5 nước ấm). Thả chả nướng và dưa góp đu đủ vào bát nước chấm.',
            durationMinutes: 10,
          ),
        ],
      ),
      Recipe(
        id: 'rec_5',
        title: 'Trà Đào Cam Sả Tươi Thanh Nhiệt',
        category: 'Đồ uống',
        imageUrl:
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=800&auto=format&fit=crop&q=80',
        chefName: 'Barista Vy Vy',
        chefAvatar: '',
        rating: 4.7,
        reviewsCount: 142,
        cookTimeMinutes: 10,
        difficulty: 'Dễ',
        calories: 140,
        servings: 2,
        tags: ['#TràĐào', '#GiảiNhiệt', '#ĐồUống', '#MùaHè'],
        isFavorite: true,
        isSaved: true,
        cookedCount: 8,
        lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
        ingredients: [
          Ingredient(
            id: 'i51',
            name: 'Trà túi lọc hương đào Cozy',
            amount: '2 gói',
          ),
          Ingredient(id: 'i52', name: 'Sả tươi đập dập', amount: '3 cây'),
          Ingredient(
            id: 'i53',
            name: 'Cam vàng cắt lát & vắt lấy nước',
            amount: '1 quả',
          ),
          Ingredient(
            id: 'i54',
            name: 'Đào ngâm giòn Kronos',
            amount: '4 miếng',
          ),
          Ingredient(
            id: 'i55',
            name: 'Nước cốt đường mía & đá viên',
            amount: '1 ly',
          ),
        ],
        steps: [
          const CookingStep(
            stepNumber: 1,
            title: 'Ủ trà cùng sả tươi',
            description:
                'Đun sôi sả tươi trong 300ml nước rồi dùng nước sôi này ủ trà túi lọc trong 5-7 phút.',
            tip: 'Đập dập sả giúp tinh dầu sả khuếch tán mùi thơm thơm ngát.',
            durationMinutes: 5,
          ),
          const CookingStep(
            stepNumber: 2,
            title: 'Lắc trà cùng nước cam & đá',
            description:
                'Cho nước cốt trà, nước cam tươi, nước đường và đá viên vào bình lắc (shaker) lắc đều trong 15 giây.',
            durationMinutes: 3,
          ),
          const CookingStep(
            stepNumber: 3,
            title: 'Trang trí & Thưởng thức',
            description:
                'Rót trà ra ly cao, xếp miếng đào ngâm giòn và lát cam vàng lên trên, trang trí cọng sả tươi.',
            durationMinutes: 2,
          ),
        ],
      ),
      Recipe(
        id: 'rec_6',
        title: 'Tôm Rim Thịt Ba Chỉ Nước Dừa Đậm Vị',
        category: 'Món chính',
        imageUrl:
            'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800&auto=format&fit=crop&q=80',
        chefName: 'Mẹ Bắp',
        chefAvatar: '',
        rating: 4.8,
        reviewsCount: 165,
        cookTimeMinutes: 25,
        difficulty: 'Dễ',
        calories: 490,
        servings: 4,
        tags: ['#CơmNhà', '#TômRim', '#MónMặn', '#BữaTối'],
        isFavorite: false,
        isSaved: true,
        cookedCount: 5,
        lastViewedAt: DateTime.now().subtract(const Duration(days: 4)),
        ingredients: [
          Ingredient(
            id: 'i61',
            name: 'Tôm đồng hoặc tôm đất tươi',
            amount: '300g',
          ),
          Ingredient(id: 'i62', name: 'Thịt ba chỉ thái mỏng', amount: '250g'),
          Ingredient(id: 'i63', name: 'Nước dừa xiêm tươi', amount: '150ml'),
          Ingredient(
            id: 'i64',
            name: 'Hành tím, tỏi, ớt băm nhuyễn',
            amount: '2 muỗng',
          ),
          Ingredient(
            id: 'i65',
            name: 'Nước mắm, đường thốt nốt, tiêu xay',
            amount: 'Vừa đủ',
          ),
        ],
        steps: [
          const CookingStep(
            stepNumber: 1,
            title: 'Sơ chế tôm & xào thịt cháy cạnh',
            description:
                'Cắt râu tôm rửa sạch. Xào thịt ba chỉ trên chảo cho ra bớt mỡ và xém cạnh vàng ươm.',
            durationMinutes: 8,
          ),
          const CookingStep(
            stepNumber: 2,
            title: 'Rim tôm thịt cùng nước dừa',
            description:
                'Phi thơm hành tỏi với mỡ heo, trút tôm vào đảo đỏ au. Cho thịt ba chỉ, nước mắm, đường và nước dừa vào rim lửa nhỏ.',
            tip:
                'Rim đến khi nước dừa keo lại sền sệt bọc lấy từng con tôm bóng bẩy.',
            durationMinutes: 12,
          ),
          const CookingStep(
            stepNumber: 3,
            title: 'Hoàn thiện với tiêu xanh',
            description:
                'Rắc nhiều tiêu xay và hành lá cắt khúc lên trên rồi tắt bếp. Món này ăn cùng cơm nóng là chuẩn vị tuyệt đối.',
            durationMinutes: 5,
          ),
        ],
      ),
      Recipe(
        id: 'rec_7',
        title: 'Bánh Mì Hoa Cúc Bơ Sữa Pháp Siêu Mềm',
        category: 'Bánh ngọt',
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop&q=80',
        chefName: 'Bếp Bánh TiTi',
        chefAvatar: '',
        rating: 4.9,
        reviewsCount: 310,
        cookTimeMinutes: 60,
        difficulty: 'Trung bình',
        calories: 380,
        servings: 6,
        tags: ['#LàmBánh', '#BánhMìHoaCúc', '#BơSữa', '#TrángMiệng'],
        isFavorite: true,
        isSaved: true,
        cookedCount: 1,
        lastViewedAt: DateTime.now().subtract(const Duration(days: 5)),
        ingredients: [
          Ingredient(
            id: 'i71',
            name: 'Bột mì số 13 (Bread flour)',
            amount: '350g',
          ),
          Ingredient(id: 'i72', name: 'Bơ lạt động vật Anchor', amount: '100g'),
          Ingredient(id: 'i73', name: 'Trứng gà tươi để mát', amount: '3 quả'),
          Ingredient(
            id: 'i74',
            name: 'Men ngọt khô (Instant yeast)',
            amount: '5g',
          ),
          Ingredient(
            id: 'i75',
            name: 'Tinh chất hoa cam Pháp',
            amount: '1 muỗng cafe',
          ),
          Ingredient(
            id: 'i76',
            name: 'Hạnh nhân lát & đường ngọc trai',
            amount: '30g',
          ),
        ],
        steps: [
          const CookingStep(
            stepNumber: 1,
            title: 'Nhồi bột đạt màng mỏng',
            description:
                'Trộn bột mì, trứng, đường, men. Nhồi khoảng 10 phút rồi cho bơ lạnh vào nhồi tiếp đến khi kéo màng mỏng.',
            tip:
                'Bơ phải giữ ở nhiệt độ mát để tránh làm chảy bơ khi nhồi bột.',
            durationMinutes: 25,
          ),
          const CookingStep(
            stepNumber: 2,
            title: 'Ủ bột & Tạo hình hoa cúc 3 bím',
            description:
                'Ủ bột nở gấp đôi trong tủ lạnh 2 tiếng. Chia bột thành 3 dải dài và thắt bím hoa cúc rồi đặt vào khuôn.',
            durationMinutes: 15,
          ),
          const CookingStep(
            stepNumber: 3,
            title: 'Nướng bánh vàng óng',
            description:
                'Quét trứng mặt bánh, rắc hạnh nhân lát. Nướng ở 170°C trong 25-30 phút đến khi bánh vàng ươm thơm lừng.',
            durationMinutes: 20,
          ),
        ],
      ),
    ]);

    _collections.addAll([
      RecipeCollection(
        id: 'col_1',
        name: 'Món Eat Clean & Healthy Dáng Xinh',
        description:
            'Tổng hợp các món giàu protein, ít calo cho thực đơn giữ dáng',
        coverImageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
        colorValue: 0xFF2A9D8F,
        recipeIds: ['rec_2'],
      ),
      RecipeCollection(
        id: 'col_2',
        name: 'Mâm Cơm Gia Đình Chuẩn Vị Việt',
        description: 'Những món mặn canh ngọt đậm đà hương vị quê hương',
        coverImageUrl:
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=600&auto=format&fit=crop&q=80',
        colorValue: 0xFFE76F51,
        recipeIds: ['rec_1', 'rec_4', 'rec_6'],
      ),
      RecipeCollection(
        id: 'col_3',
        name: 'Bữa Tối Nhanh Gọn < 20 Phút',
        description: 'Món ngon tiện lợi sau ngày dài làm việc bận rộn',
        coverImageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
        colorValue: 0xFF457B9D,
        recipeIds: ['rec_2', 'rec_3', 'rec_5'],
      ),
      RecipeCollection(
        id: 'col_4',
        name: 'Tiệm Bánh & Tráng Miệng Ngọt Ngào',
        description: 'Công thức làm bánh nướng, bánh ngọt và đồ uống mát lạnh',
        coverImageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
        colorValue: 0xFF9C27B0,
        recipeIds: ['rec_5', 'rec_7'],
      ),
    ]);

    _shoppingList.addAll([
      ShoppingItem(
        id: 'shop_1',
        name: 'Thịt bò phi lê tươi',
        amount: '350g',
        recipeSource: 'Phở Bò Tái Lăn Hà Nội',
        isCompleted: false,
      ),
      ShoppingItem(
        id: 'shop_2',
        name: 'Bánh phở tươi sợi mềm',
        amount: '500g',
        recipeSource: 'Phở Bò Tái Lăn Hà Nội',
        isCompleted: true,
      ),
      ShoppingItem(
        id: 'shop_3',
        name: 'Ức gà phi lê không da',
        amount: '250g',
        recipeSource: 'Salad Ức Gà Áp Chảo',
        isCompleted: false,
      ),
      ShoppingItem(
        id: 'shop_4',
        name: 'Sốt mè rang Kewpie',
        amount: '1 chai',
        recipeSource: 'Salad Ức Gà Áp Chảo',
        isCompleted: true,
      ),
      ShoppingItem(
        id: 'shop_5',
        name: 'Bơ lạt Anchor',
        amount: '100g',
        recipeSource: 'Bánh Mì Hoa Cúc',
        isCompleted: false,
      ),
    ]);
  }
}

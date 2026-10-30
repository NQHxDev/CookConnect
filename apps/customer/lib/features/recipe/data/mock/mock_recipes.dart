import 'package:cookconnect/features/recipe/data/models/recipe.dart';
import 'package:cookconnect/features/recipe/data/mock/mock_recipes_part2.dart';

List<Recipe> getInitialRecipes() {
  return [
    // -------------------------------------------------------------------------
    // 1. Phở Bò Tái Lăn Hà Nội Chuẩn Vị
    // -------------------------------------------------------------------------
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
        Ingredient(id: 'i1_1', name: 'Bánh phở tươi', amount: '500g'),
        Ingredient(id: 'i1_2', name: 'Thịt bò phi lê', amount: '350g'),
        Ingredient(
          id: 'i1_3',
          name: 'Xương ống bò hầm nước dùng',
          amount: '1kg',
        ),
        Ingredient(
          id: 'i1_4',
          name: 'Hành hoa, rau mùi, húng quế',
          amount: '100g',
        ),
        Ingredient(
          id: 'i1_5',
          name: 'Hoa hồi, quế, thảo quả nướng',
          amount: '1 gói',
        ),
        Ingredient(id: 'i1_6', name: 'Gừng nướng & hành khô', amount: '50g'),
        Ingredient(
          id: 'i1_7',
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

    // -------------------------------------------------------------------------
    // 2. Salad Ức Gà Áp Chảo Sốt Mè Rang
    // -------------------------------------------------------------------------
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
        Ingredient(id: 'i2_1', name: 'Ức gà phi lê không da', amount: '250g'),
        Ingredient(
          id: 'i2_2',
          name: 'Xà lách Romaine & bắp cải tím',
          amount: '150g',
        ),
        Ingredient(
          id: 'i2_3',
          name: 'Cà chua bi & dưa chuột baby',
          amount: '100g',
        ),
        Ingredient(
          id: 'i2_4',
          name: 'Sốt mè rang Kewpie',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i2_5',
          name: 'Dầu ô liu, muối hồng, tiêu đen',
          amount: '1 thìa cafe',
        ),
        Ingredient(id: 'i2_6', name: 'Trứng gà luộc lòng đào', amount: '1 quả'),
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

    // -------------------------------------------------------------------------
    // 3. Bò Sốt Tiêu Đen Kèm Bánh Mì Giòn
    // -------------------------------------------------------------------------
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
        Ingredient(id: 'i3_1', name: 'Thịt thăn bò tươi', amount: '400g'),
        Ingredient(id: 'i3_2', name: 'Ớt chuông xanh đỏ', amount: '1 quả'),
        Ingredient(id: 'i3_3', name: 'Hành tây trắng', amount: '1 củ'),
        Ingredient(id: 'i3_4', name: 'Tiêu đen xay vỡ', amount: '2 muỗng cafe'),
        Ingredient(
          id: 'i3_5',
          name: 'Dầu hào, bơ lạt, tỏi băm',
          amount: '2 muỗng',
        ),
        Ingredient(
          id: 'i3_6',
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

    // -------------------------------------------------------------------------
    // 4. Bún Chả Nướng Than Hoa Hà Nội
    // -------------------------------------------------------------------------
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
        Ingredient(id: 'i4_1', name: 'Thịt ba chỉ rút sườn', amount: '400g'),
        Ingredient(id: 'i4_2', name: 'Thịt nạc vai xay', amount: '350g'),
        Ingredient(id: 'i4_3', name: 'Bún tươi sợi nhỏ', amount: '800g'),
        Ingredient(
          id: 'i4_4',
          name: 'Đu đủ xanh & cà rốt giòn',
          amount: '1 củ',
        ),
        Ingredient(
          id: 'i4_5',
          name: 'Nước mắm, đường nâu, giấm, tỏi ớt',
          amount: 'Vừa đủ',
        ),
        Ingredient(
          id: 'i4_6',
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

    // -------------------------------------------------------------------------
    // 5. Trà Đào Cam Sả Tươi Thanh Nhiệt
    // -------------------------------------------------------------------------
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
          id: 'i5_1',
          name: 'Trà túi lọc hương đào Cozy',
          amount: '2 gói',
        ),
        Ingredient(id: 'i5_2', name: 'Sả tươi đập dập', amount: '3 cây'),
        Ingredient(
          id: 'i5_3',
          name: 'Cam vàng cắt lát & vắt lấy nước',
          amount: '1 quả',
        ),
        Ingredient(id: 'i5_4', name: 'Đào ngâm giòn Kronos', amount: '4 miếng'),
        Ingredient(
          id: 'i5_5',
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
          tip: 'Đập dập sả giúp tinh dầu sả khuếch tán mùi thơm ngát.',
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

    // -------------------------------------------------------------------------
    // 6. Tôm Rim Thịt Ba Chỉ Nước Dừa Đậm Vị
    // -------------------------------------------------------------------------
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
          id: 'i6_1',
          name: 'Tôm đồng hoặc tôm đất tươi',
          amount: '300g',
        ),
        Ingredient(id: 'i6_2', name: 'Thịt ba chỉ thái mỏng', amount: '250g'),
        Ingredient(id: 'i6_3', name: 'Nước dừa xiêm tươi', amount: '150ml'),
        Ingredient(
          id: 'i6_4',
          name: 'Hành tím, tỏi, ớt băm nhuyễn',
          amount: '2 muỗng',
        ),
        Ingredient(
          id: 'i6_5',
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

    // -------------------------------------------------------------------------
    // 7. Bánh Mì Hoa Cúc Bơ Sữa Pháp Siêu Mềm
    // -------------------------------------------------------------------------
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
          id: 'i7_1',
          name: 'Bột mì số 13 (Bread flour)',
          amount: '350g',
        ),
        Ingredient(id: 'i7_2', name: 'Bơ lạt động vật Anchor', amount: '100g'),
        Ingredient(id: 'i7_3', name: 'Trứng gà tươi để mát', amount: '3 quả'),
        Ingredient(
          id: 'i7_4',
          name: 'Men ngọt khô (Instant yeast)',
          amount: '5g',
        ),
        Ingredient(
          id: 'i7_5',
          name: 'Tinh chất hoa cam Pháp',
          amount: '1 muỗng cafe',
        ),
        Ingredient(
          id: 'i7_6',
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
          tip: 'Bơ phải giữ ở nhiệt độ mát để tránh làm chảy bơ khi nhồi bột.',
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

    // -------------------------------------------------------------------------
    // 8. Cơm Tấm Sườn Bì Chả Sài Gòn Chuẩn Vị
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_8',
      title: 'Cơm Tấm Sườn Bì Chả Sài Gòn Chuẩn Vị',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Hữu Đức',
      chefAvatar: '',
      rating: 4.9,
      reviewsCount: 420,
      cookTimeMinutes: 40,
      difficulty: 'Trung bình',
      calories: 680,
      servings: 3,
      tags: ['#CơmTấm', '#SườnNướng', '#SàiGòn', '#ĐặcSảnMiềnNam'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 7,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ingredients: [
        Ingredient(id: 'i8_1', name: 'Gạo tấm thơm dẻo', amount: '400g'),
        Ingredient(
          id: 'i8_2',
          name: 'Sườn cốt lết heo có mỡ viền',
          amount: '500g',
        ),
        Ingredient(
          id: 'i8_3',
          name: 'Bì heo trộn thính gạo rang',
          amount: '150g',
        ),
        Ingredient(
          id: 'i8_4',
          name: 'Trứng vịt, nấm mèo, thịt xay làm chả hấp',
          amount: '3 quả',
        ),
        Ingredient(
          id: 'i8_5',
          name: 'Mỡ hành lá tươi & tóp mỡ giòn',
          amount: '50g',
        ),
        Ingredient(
          id: 'i8_6',
          name: 'Đồ chua củ cải cà rốt & nước mắm tỏi ớt',
          amount: '1 bát',
        ),
        Ingredient(
          id: 'i8_7',
          name: 'Sữa đặc, mật ong, sả băm ướp sườn',
          amount: '3 muỗng canh',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ướp sườn cốt lết bí truyền',
          description:
              'Dần mềm sườn. Ướp với sả băm, tỏi, hành tím, nước mắm, mật ong, một chút sữa đặc và dầu hào trong ít nhất 2 giờ.',
          tip:
              'Một thìa nhỏ sữa đặc giúp thớ thịt sườn nướng siêu mềm và không bị khô.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Hấp chả trứng & Nướng sườn',
          description:
              'Trộn thịt xay, nấm mèo, bún tàu và lòng đỏ trứng hấp 25 phút. Nướng sườn trên bếp than hoặc nồi chiên không dầu ở 180°C.',
          durationMinutes: 20,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Xới cơm tấm & Chan mỡ hành',
          description:
              'Xới cơm tấm ra đĩa, đặt miếng sườn nướng xém cạnh, lát chả trứng vàng ươm, bì thính, rưới mỡ hành tóp mỡ và ăn kèm nước mắm ngọt keo.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 9. Bún Bò Huế Đậm Đà Chuẩn Vị Cố Đô
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_9',
      title: 'Bún Bò Huế Đậm Đà Chuẩn Vị Cố Đô',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
      chefName: 'Mệ Như xứ Huế',
      chefAvatar: '',
      rating: 4.95,
      reviewsCount: 630,
      cookTimeMinutes: 50,
      difficulty: 'Khó',
      calories: 620,
      servings: 5,
      tags: ['#BúnBòHuế', '#CốĐô', '#MónNước', '#ĐậmĐà'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 4,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ingredients: [
        Ingredient(
          id: 'i9_1',
          name: 'Bắp bò hoa & nạm bò tươi',
          amount: '600g',
        ),
        Ingredient(id: 'i9_2', name: 'Giò heo rút xương', amount: '500g'),
        Ingredient(id: 'i9_3', name: 'Chả cua Huế & huyết heo', amount: '200g'),
        Ingredient(id: 'i9_4', name: 'Bún bò sợi to xứ Huế', amount: '800g'),
        Ingredient(
          id: 'i9_5',
          name: 'Mắm ruốc Huế nguyên chất',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i9_6',
          name: 'Sả cây đập dập & ớt sa tế cay',
          amount: '6 cây',
        ),
        Ingredient(
          id: 'i9_7',
          name: 'Rau chuối bào, hoa chuối, giá đỗ, rau răm',
          amount: '300g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Hầm xương bò & Nấu cốt mắm ruốc',
          description:
              'Hầm bắp bò và giò heo cùng bó sả đập dập. Hòa mắm ruốc Huế với nước lạnh, lắng lấy nước trong rồi trút vào nồi nước dùng thơm lừng.',
          tip:
              'Chỉ lấy phần nước trong của mắm ruốc để nước dùng thanh dịu không gắt mùi nồng.',
          durationMinutes: 30,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Thắng dầu màu điều & Thả chả cua',
          description:
              'Phi dầu hạt điều cùng hành tím, tỏi và ớt bột Huế cho màu đỏ rực rỡ, đổ vào nồi nước lèo. Thả chả cua vo viên và huyết heo chín vào.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Hoàn thiện tô bún bò Huế bốc khói',
          description:
              'Trần bún sợi to, xếp bắp bò thái mỏng, khoanh giò gân, chả cua, rắc hành hoa rau răm, chan nước lèo đỏ au óng ả và thêm sa tế.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 10. Bánh Xèo Miền Tây Giòn Rụm Tôm Nhảy
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_10',
      title: 'Bánh Xèo Miền Tây Giòn Rụm Tôm Nhảy',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1627308595229-7830a5c91f9f?w=800&auto=format&fit=crop&q=80',
      chefName: 'Út Nhỏ Miền Tây',
      chefAvatar: '',
      rating: 4.85,
      reviewsCount: 310,
      cookTimeMinutes: 35,
      difficulty: 'Trung bình',
      calories: 450,
      servings: 4,
      tags: ['#BánhXèo', '#MiềnTây', '#GiònRụm', '#ĂnVặt'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 2,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(id: 'i10_1', name: 'Bột bánh xèo Hương Xưa', amount: '400g'),
        Ingredient(id: 'i10_2', name: 'Nước cốt dừa béo ngậy', amount: '200ml'),
        Ingredient(id: 'i10_3', name: 'Tôm đất tươi còn nhảy', amount: '300g'),
        Ingredient(id: 'i10_4', name: 'Thịt ba rọi thái mỏng', amount: '250g'),
        Ingredient(
          id: 'i10_5',
          name: 'Giá đỗ tươi & đậu xanh hấp chín',
          amount: '200g',
        ),
        Ingredient(
          id: 'i10_6',
          name: 'Bia lạnh hoặc nước có ga',
          amount: '100ml',
        ),
        Ingredient(
          id: 'i10_7',
          name: 'Rau rừng Tây Ninh & cải bẹ xanh',
          amount: '300g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Pha bột bánh xèo siêu giòn lâu',
          description:
              'Khuấy bột bánh xèo cùng nước cốt dừa, hành lá cắt nhỏ, bột nghệ và 100ml bia lạnh. Để bột nghỉ 20 phút.',
          tip:
              'Bia lạnh giúp vỏ bánh xèo nở bọt khí li ti, giòn tan suốt cả tiếng đồng hồ.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Đổ bánh xèo xèo trên chảo lớn',
          description:
              'Chảo gang thật nóng, trút tôm thịt vào xào sơ. Múc vá bột tráng mỏng vòng quanh chảo, rắc giá đỗ và đậy nắp 2 phút cho vành bánh giòn cuộn lại.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Cuốn rau rừng & Chấm nước mắm chua ngọt',
          description:
              'Gấp đôi bánh xèo vàng ươm ra đĩa. Bẻ miếng bánh giòn tan cuốn cùng đọt cóc, xà lách, lá quế chấm ngập nước mắm tỏi ớt cà rốt bào.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 11. Bún Đậu Mắm Tôm Thập Cẩm Hà Nội
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_11',
      title: 'Bún Đậu Mắm Tôm Thập Cẩm Hà Nội',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Cụ Lý Phố Cổ',
      chefAvatar: '',
      rating: 4.9,
      reviewsCount: 470,
      cookTimeMinutes: 30,
      difficulty: 'Dễ',
      calories: 590,
      servings: 3,
      tags: ['#BúnĐậu', '#MắmTôm', '#HàNội', '#ĂnVặt', '#ThậpCẩm'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 5,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(id: 'i11_1', name: 'Bún lá cắt miếng vuông', amount: '500g'),
        Ingredient(id: 'i11_2', name: 'Đậu phụ Mơ lướt ván', amount: '4 bìa'),
        Ingredient(id: 'i11_3', name: 'Chả cốm Hà Nội tươi', amount: '200g'),
        Ingredient(
          id: 'i11_4',
          name: 'Thịt chân giò luộc thái mỏng',
          amount: '300g',
        ),
        Ingredient(
          id: 'i11_5',
          name: 'Nem rán giòn rụm & dồi sụn nướng',
          amount: '200g',
        ),
        Ingredient(
          id: 'i11_6',
          name: 'Mắm tôm Thanh Hóa ngon loại 1',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i11_7',
          name: 'Quất tươi, ớt chỉ thiên, đường, rượu trắng',
          amount: 'Vừa đủ',
        ),
        Ingredient(
          id: 'i11_8',
          name: 'Rau kinh giới, tía tô, dưa leo',
          amount: '150g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Chiên đậu phụ giòn vỏ mềm ruột',
          description:
              'Cắt đậu phụ Mơ thành miếng vuông vừa ăn. Đun dầu sôi ngập chảo, chiên đậu trên lửa vừa đến khi lớp vỏ ngoài vàng rụm phồng xốp.',
          tip:
              'Đậu phụ làng Mơ chiên lướt ván giữ trọn độ béo mịn, tan chảy nơi đầu lưỡi.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Chiên chả cốm & Luộc thịt bắp giò',
          description:
              'Chiên chả cốm thơm dẻo hạt cốm xanh. Thịt chân giò bó tròn luộc chín ngâm nước đá lạnh rồi thái lát mỏng tang.',
          durationMinutes: 12,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Đánh bông mắm tôm sủi bọt trắng',
          description:
              'Cho mắm tôm, đường cát, vài giọt rượu trắng và nước cốt quất vào bát. Dùng đũa đánh bông sủi bọt trắng mịn, rưới thêm 1 thìa dầu sôi vừa rán đậu.',
          tip:
              'Thìa dầu ăn sôi nóng giúp mắm tôm thơm ngậy và khử hoàn toàn vị tanh.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 12. Lẩu Thái Hải Sản Chua Cay Thơm Nồng
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_12',
      title: 'Lẩu Thái Hải Sản Chua Cay Thơm Nồng',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Somchai',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 395,
      cookTimeMinutes: 40,
      difficulty: 'Trung bình',
      calories: 550,
      servings: 6,
      tags: ['#LẩuThái', '#HảiSản', '#TomYum', '#TiệcCuốiTuần'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 4)),
      ingredients: [
        Ingredient(
          id: 'i12_1',
          name: 'Tôm sú tươi & mực nang khía hoa',
          amount: '500g',
        ),
        Ingredient(id: 'i12_2', name: 'Nghêu trắng sống', amount: '500g'),
        Ingredient(id: 'i12_3', name: 'Ba chỉ bò Mỹ cuộn lát', amount: '350g'),
        Ingredient(
          id: 'i12_4',
          name: 'Cốt sốt Tom Yum Thái & lá chúc (chanh Thái)',
          amount: '1 hũ',
        ),
        Ingredient(
          id: 'i12_5',
          name: 'Sả cây, riềng non, ớt hiểm, cà chua bi',
          amount: '100g',
        ),
        Ingredient(
          id: 'i12_6',
          name: 'Nấm kim châm, nấm đùi gà, ngô ngọt',
          amount: '300g',
        ),
        Ingredient(
          id: 'i12_7',
          name: 'Rau muống, cải thảo, hoa chuối, bún tươi',
          amount: '400g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nấu nước cốt lẩu Tom Yum thơm ngát',
          description:
              'Hầm nước dùng từ xương ống hoặc nước dừa tươi. Phi thơm riềng non, sả đập dập, lá chanh Thái, cho sốt Tom Yum và cà chua vào đảo đều.',
          tip:
              'Vò nhẹ lá chanh Thái trước khi thả vào nước lẩu để tinh dầu thơm bung tỏa tối đa.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Sơ chế hải sản & rau nấm',
          description:
              'Tôm cắt râu, mực khía mắt lưới đẹp mắt. Nghêu ngâm ớt cay nhả sạch cát. Rửa sạch các loại nấm tươi và rau xanh ăn kèm.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Thưởng thức nồi lẩu bốc khói',
          description:
              'Bắc nồi lẩu lên bếp, thả nghêu và ngô ngọt vào trước tạo độ ngọt tự nhiên. Nhúng tôm, mực, bò Mỹ và rau nấm ăn cùng bún tươi hoặc mì tôm.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 13. Gà Cay Sốt Phô Mai Kéo Sợi Hàn Quốc
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_13',
      title: 'Gà Cay Sốt Phô Mai Kéo Sợi Hàn Quốc',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1562967914-608f82629710?w=800&auto=format&fit=crop&q=80',
      chefName: 'Oppa Kim Kitchen',
      chefAvatar: '',
      rating: 4.82,
      reviewsCount: 280,
      cookTimeMinutes: 25,
      difficulty: 'Dễ',
      calories: 640,
      servings: 3,
      tags: ['#GàCay', '#PhôMai', '#HànQuốc', '#Buldak', '#MónNgon'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 2,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 5)),
      ingredients: [
        Ingredient(
          id: 'i13_1',
          name: 'Má đùi gà rút xương mềm mọng',
          amount: '500g',
        ),
        Ingredient(
          id: 'i13_2',
          name: 'Phô mai Mozzarella bào sợi kéo dài',
          amount: '250g',
        ),
        Ingredient(
          id: 'i13_3',
          name: 'Tương ớt Hàn Quốc Gochujang',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i13_4',
          name: 'Ớt bột Hàn Quốc & mật ong hoa rừng',
          amount: '2 muỗng',
        ),
        Ingredient(
          id: 'i13_5',
          name: 'Xì dầu, dầu mè thơm, tỏi băm nhuyễn',
          amount: '2 muỗng',
        ),
        Ingredient(
          id: 'i13_6',
          name: 'Bánh gạo Tokbokki & mè rang vàng',
          amount: '150g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ướp thịt gà sốt Gochujang đỏ rực',
          description:
              'Thái má đùi gà thành miếng vuông vừa ăn. Trộn đều cùng sốt Gochujang, ớt bột, mật ong, dầu mè và tỏi băm trong 15 phút.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào gà cay cùng bánh gạo Tokbokki',
          description:
              'Làm nóng chảo sâu lòng, trút gà đã ướp và bánh gạo vào xào chín săn trên lửa vừa cho nước sốt sánh đặc bọc lấy thịt gà.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Phủ phô mai Mozzarella chảy sợi',
          description:
              'Rải ngập phô mai Mozzarella lên trên mặt chảo gà. Đậy nắp chảo 3 phút cho phô mai tan chảy béo ngậy kéo sợi dài tít tắp, rắc mè rang thơm lừng.',
          tip:
              'Dùng chảo gang giữ nhiệt lâu để phô mai luôn dẻo dai kéo sợi nóng hổi.',
          durationMinutes: 7,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 14. Bánh Mì Chảo Xíu Mại Sốt Bơ Pate Cột Đèn
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_14',
      title: 'Bánh Mì Chảo Xíu Mại Sốt Bơ Pate Cột Đèn',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Bánh Mì Phố',
      chefAvatar: '',
      rating: 4.87,
      reviewsCount: 360,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 560,
      servings: 2,
      tags: ['#BánhMìChảo', '#PateCộtĐèn', '#BữaSáng', '#ĂnVặt', '#NhanhGọn'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 9,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 18)),
      ingredients: [
        Ingredient(
          id: 'i14_1',
          name: 'Bánh mì baguette nướng giòn rụm',
          amount: '2 ổ',
        ),
        Ingredient(id: 'i14_2', name: 'Trứng gà ta lòng đào', amount: '2 quả'),
        Ingredient(
          id: 'i14_3',
          name: 'Pate gan béo Cột Đèn Hải Phòng',
          amount: '100g',
        ),
        Ingredient(
          id: 'i14_4',
          name: 'Xúc xích Đức xông khói & thịt nguội',
          amount: '2 cây',
        ),
        Ingredient(
          id: 'i14_5',
          name: 'Xíu mại sốt cà chua đậm đà',
          amount: '2 viên',
        ),
        Ingredient(
          id: 'i14_6',
          name: 'Bơ lạt thơm lừng & tiêu đen đập dập',
          amount: '1 muỗng',
        ),
        Ingredient(
          id: 'i14_7',
          name: 'Dưa leo giòn mát & rau mùi ta',
          amount: '50g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Đun nóng chảo gang với bơ lạt',
          description:
              'Cho miếng bơ lạt vào chảo gang đun tan chảy xèo xèo thơm ngát. Khía xúc xích và cho vào chiên căng bóng bề mặt.',
          durationMinutes: 4,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Ốp la trứng & Xếp pate xíu mại',
          description:
              'Đập trứng gà vào chảo ốp la lòng đào. Xếp pate béo ngậy, viên xíu mại nóng hổi và rưới nước sốt cà chua sền sệt lên trên.',
          tip:
              'Để lửa vừa để lòng trắng chín giòn đáy nhưng lòng đỏ vẫn béo ngậy sóng sánh.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Thưởng thức chấm bánh mì giòn tan',
          description:
              'Rắc nhiều tiêu xay lên trứng, dùng nóng trực tiếp trên chảo gang cùng bánh mì giòn rụm chấm đẫm sốt bơ trứng pate.',
          durationMinutes: 6,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 15. Bún Riêu Cua Đồng Thanh Mát Chuẩn Vị Bắc
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_15',
      title: 'Bún Riêu Cua Đồng Thanh Mát Chuẩn Vị Bắc',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=800&auto=format&fit=crop&q=80',
      chefName: 'Cô Tấm Hà Thành',
      chefAvatar: '',
      rating: 4.92,
      reviewsCount: 520,
      cookTimeMinutes: 45,
      difficulty: 'Trung bình',
      calories: 480,
      servings: 4,
      tags: ['#BúnRiêu', '#CuaĐồng', '#ThanhMát', '#HàNội', '#MónNước'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(
          id: 'i15_1',
          name: 'Cua đồng tươi giã nhuyễn lọc lấy nước',
          amount: '500g',
        ),
        Ingredient(id: 'i15_2', name: 'Bún tươi sợi nhỏ', amount: '700g'),
        Ingredient(
          id: 'i15_3',
          name: 'Đậu phụ chiên phồng vàng rụm',
          amount: '3 bìa',
        ),
        Ingredient(
          id: 'i15_4',
          name: 'Cà chua chín mọng bổ múi cau',
          amount: '3 quả',
        ),
        Ingredient(
          id: 'i15_5',
          name: 'Giấm bỗng nếp thơm chua dịu',
          amount: '4 muỗng canh',
        ),
        Ingredient(
          id: 'i15_6',
          name: 'Gạch cua chưng dầu màu điều',
          amount: '50g',
        ),
        Ingredient(
          id: 'i15_7',
          name: 'Rau sống: hoa chuối, kinh giới, xà lách thái nhỏ',
          amount: '250g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nấu riêu cua đóng tảng béo ngậy',
          description:
              'Cho nước cua đã lọc vào nồi, thêm chút muối tinh. Đun lửa vừa và khuấy nhẹ đáy nồi đến khi gạch cua nổi lên kết thành từng tảng lớn thì hạ lửa nhỏ.',
          tip:
              'Khi thịt cua bắt đầu nổi, ngừng khuấy để riêu cua kết tảng dày dặn không bị nát vỡ.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào cà chua & Nêm giấm bỗng nếp',
          description:
              'Xào cà chua chín tới với dầu màu điều cho màu đỏ cam tự nhiên. Trút vào nồi nước dùng cùng đậu chiên vàng, nêm giấm bỗng nếp chua thanh thanh.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trình bày tô bún riêu cua thơm lừng',
          description:
              'Trần bún vào bát, múc tảng riêu cua, đậu vàng, cà chua, rắc hành hoa tía tô, chan nước dùng chua dịu óng ánh gạch cua chưng thơm phức.',
          durationMinutes: 15,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 16. Cá Hồi Áp Chảo Sốt Bơ Chanh Măng Tây
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_16',
      title: 'Cá Hồi Áp Chảo Sốt Bơ Chanh Măng Tây',
      category: 'Eat Clean',
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Daniel Phạm',
      chefAvatar: '',
      rating: 4.96,
      reviewsCount: 290,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 420,
      servings: 2,
      tags: ['#CáHồi', '#EatClean', '#Healthy', '#SốtBơChanh', '#MăngTây'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 6,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ingredients: [
        Ingredient(
          id: 'i16_1',
          name: 'Phi lê cá hồi tươi Na Uy có da',
          amount: '350g',
        ),
        Ingredient(
          id: 'i16_2',
          name: 'Măng tây xanh loại 1 non giòn',
          amount: '150g',
        ),
        Ingredient(id: 'i16_3', name: 'Bơ lạt cao cấp Anchor', amount: '30g'),
        Ingredient(
          id: 'i16_4',
          name: 'Nước cốt chanh vàng & vỏ chanh bào',
          amount: '2 thìa canh',
        ),
        Ingredient(
          id: 'i16_5',
          name: 'Dầu ô liu, muối hồng Himalaya, tiêu đen',
          amount: '1 thìa cafe',
        ),
        Ingredient(
          id: 'i16_6',
          name: 'Lá hương thảo (Rosemary) tươi & tỏi tép',
          amount: '2 nhánh',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ướp cá hồi & Sơ chế măng tây',
          description:
              'Thấm khô miếng cá hồi. Rắc muối hồng và tiêu xay đều hai mặt cá. Măng tây tước xơ phần gốc bẻ khúc.',
          tip:
              'Bề mặt da cá hồi phải thật khô ráo để khi áp chảo da giòn rụm không bị dính chảo.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Áp chảo cá hồi da giòn rụm',
          description:
              'Đun nóng chảo dầu ô liu, đặt mặt da cá xuống áp chảo trong 4 phút cho da vàng giòn tan. Lật mặt thịt áp chảo tiếp 2-3 phút cùng nhánh hương thảo và tỏi đập dập.',
          durationMinutes: 7,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Làm sốt bơ chanh & Xào măng tây',
          description:
              'Cho bơ lạt, nước cốt chanh vàng, vỏ chanh bào vào chảo đun tan chảy sánh mịn. Măng tây xào nhanh 2 phút với bơ tỏi rồi rưới sốt lên cá hồi thưởng thức.',
          durationMinutes: 6,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 17. Thịt Kho Tàu Trứng Cút Nước Dừa Xiêm
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_17',
      title: 'Thịt Kho Tàu Trứng Cút Nước Dừa Xiêm',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop&q=80',
      chefName: 'Má Năm Nam Bộ',
      chefAvatar: '',
      rating: 4.89,
      reviewsCount: 380,
      cookTimeMinutes: 50,
      difficulty: 'Trung bình',
      calories: 610,
      servings: 4,
      tags: ['#ThịtKhoTàu', '#CơmMẹNấu', '#MónChính', '#NướcDừa'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 8,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i17_1',
          name: 'Thịt ba rọi rút sườn vuông vức',
          amount: '600g',
        ),
        Ingredient(
          id: 'i17_2',
          name: 'Trứng cút luộc bóc vỏ',
          amount: '20 quả',
        ),
        Ingredient(
          id: 'i17_3',
          name: 'Nước dừa xiêm ngọt thanh',
          amount: '400ml',
        ),
        Ingredient(
          id: 'i17_4',
          name: 'Hành tím, tỏi giã nhuyễn',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i17_5',
          name: 'Nước mắm nhỉ nhãn vàng',
          amount: '4 muỗng canh',
        ),
        Ingredient(
          id: 'i17_6',
          name: 'Đường cát vàng & ớt chỉ thiên',
          amount: '2 muỗng canh',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Cắt khối quân cờ & Ướp thịt thấm vị',
          description:
              'Cắt thịt miếng vuông to bản (khoảng 4x4cm). Ướp nước mắm ngon, đường, hành tỏi giã nhuyễn trong 45 phút cho mỡ trong veo.',
          tip:
              'Phơi thịt ra gió 30 phút sau khi ướp giúp lớp mỡ khi kho trong suốt như thạch.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Kho thịt cùng nước dừa xiêm',
          description:
              'Thắng nước màu đường mía cánh gián, cho thịt vào đảo săn đều. Đổ ngập nước dừa xiêm, đun sôi rồi hạ lửa riu riu không đậy nắp.',
          durationMinutes: 30,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Thả trứng cút & Hoàn tất kho sánh vàng',
          description:
              'Khi thịt bắt đầu mềm rục, thả trứng cút vào kho cùng thêm 10 phút đến khi nước kho sánh đỏ óng ả bám đều quanh từng miếng thịt mềm rục tan trong miệng.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 18. Canh Chua Cá Lóc Nam Bộ Bạc Hà Thơm Mát
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_18',
      title: 'Canh Chua Cá Lóc Nam Bộ Bạc Hà Thơm Mát',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Ba Miền',
      chefAvatar: '',
      rating: 4.84,
      reviewsCount: 260,
      cookTimeMinutes: 30,
      difficulty: 'Dễ',
      calories: 340,
      servings: 4,
      tags: ['#CanhChua', '#CáLóc', '#NamBộ', '#CơmNhà', '#MónNước'],
      isFavorite: false,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 4)),
      ingredients: [
        Ingredient(
          id: 'i18_1',
          name: 'Cá lóc đồng tươi cắt khoanh',
          amount: '500g',
        ),
        Ingredient(
          id: 'i18_2',
          name: 'Thơm (dứa) chín & cà chua',
          amount: '1 trái',
        ),
        Ingredient(
          id: 'i18_3',
          name: 'Bạc hà (dọc mùng), đậu bắp non',
          amount: '200g',
        ),
        Ingredient(
          id: 'i18_4',
          name: 'Giá đỗ sống & me chín chua thanh',
          amount: '100g',
        ),
        Ingredient(
          id: 'i18_5',
          name: 'Rau ngò ôm, ngò gai (mùi tàu)',
          amount: '1 nắm',
        ),
        Ingredient(
          id: 'i18_6',
          name: 'Tỏi phi vàng ươm & ớt sừng cay',
          amount: '2 muỗng',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nấu nước cốt me & Thả cá lóc',
          description:
              'Dầm me chín lấy nước chua. Đun sôi nước canh chua cùng thơm cắt lát, cho cá lóc vào luộc chín tới rồi vớt ra đĩa để cá không bị nát.',
          durationMinutes: 12,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Cho rau bổi & Nêm nếm đậm đà',
          description:
              'Cho cà chua, đậu bắp, bạc hà vào nồi đun sôi bùng. Nêm nước mắm cốt, đường phèn tạo vị chua ngọt hài hòa đặc trưng của miền Tây.',
          tip: 'Cho bạc hà và giá đỗ sau cùng để giữ trọn độ giòn sần sật.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rắc ngò ôm & Tỏi phi thơm nức',
          description:
              'Múc canh ra tô lớn, đặt khúc cá lóc lên trên, rắc ngò ôm, ngò gai thái nhỏ, ớt lát và phủ lớp tỏi phi thơm phức vàng giòn.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 19. Mì Quảng Tôm Thịt Đậm Đà Miền Trung
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_19',
      title: 'Mì Quảng Tôm Thịt Đậm Đà Miền Trung',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
      chefName: 'O Lan Xứ Quảng',
      chefAvatar: '',
      rating: 4.91,
      reviewsCount: 340,
      cookTimeMinutes: 35,
      difficulty: 'Trung bình',
      calories: 530,
      servings: 4,
      tags: ['#MìQuảng', '#ĐặcSảnMiềnTrung', '#TômThịt', '#MónNước'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 2,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 6)),
      ingredients: [
        Ingredient(
          id: 'i19_1',
          name: 'Sợi mì Quảng vàng óng bột nghệ',
          amount: '600g',
        ),
        Ingredient(id: 'i19_2', name: 'Tôm sông tươi cắt râu', amount: '300g'),
        Ingredient(
          id: 'i19_3',
          name: 'Thịt ba chỉ heo hoặc sườn non',
          amount: '350g',
        ),
        Ingredient(
          id: 'i19_4',
          name: 'Trứng cút luộc bóc vỏ',
          amount: '12 quả',
        ),
        Ingredient(
          id: 'i19_5',
          name: 'Dầu củ nén phi thơm nức mũi',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i19_6',
          name: 'Bánh tráng nướng mè giòn rụm',
          amount: '2 cái',
        ),
        Ingredient(
          id: 'i19_7',
          name: 'Đậu phộng rang giã dập & rau búp chuối',
          amount: '150g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Rim tôm thịt cùng củ nén đập dập',
          description:
              'Đun nóng dầu phụng, phi củ nén thật thơm. Cho tôm, thịt ba chỉ vào xào săn với bột nghệ, nước mắm, tiêu đen cho thấm đẫm vị mặn ngọt.',
          tip:
              'Củ nén là linh hồn làm nên mùi thơm nồng nàn bất hủ của Mì Quảng.',
          durationMinutes: 12,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nấu nước như ý xâm xấp đậm đặc',
          description:
              'Thêm nước hầm xương vào nồi tôm thịt rim, đun lửa nhỏ cho nước sốt ngấm sánh và cô đặc lại, chỉ chan xâm xấp mặt mì.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Bày tô mì Quảng & Bẻ bánh tráng mè',
          description:
              'Trải rau sống dưới đáy tô, xếp sợi mì Quảng lên trên, múc tôm thịt trứng cút, chan 1 vá nước như ý sánh đỏ, rắc đậu phộng và bẻ vụn bánh tráng mè.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 20. Cà Phê Muối Xứ Huế Béo Ngậy Đậm Đà
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_20',
      title: 'Cà Phê Muối Xứ Huế Béo Ngậy Đậm Đà',
      category: 'Đồ uống',
      imageUrl:
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80',
      chefName: 'Barista Minh Triết',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 390,
      cookTimeMinutes: 10,
      difficulty: 'Dễ',
      calories: 180,
      servings: 2,
      tags: ['#CàPhêMuối', '#XứHuế', '#ĐồUống', '#Trending', '#NhanhGọn'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 12,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ingredients: [
        Ingredient(
          id: 'i20_1',
          name: 'Cà phê Robusta mộc pha phin đậm đặc',
          amount: '50ml',
        ),
        Ingredient(
          id: 'i20_2',
          name: 'Kem béo thực vật (Rich lùn)',
          amount: '60ml',
        ),
        Ingredient(
          id: 'i20_3',
          name: 'Sữa tươi thanh trùng không đường',
          amount: '20ml',
        ),
        Ingredient(
          id: 'i20_4',
          name: 'Sữa đặc Ông Thọ béo ngọt',
          amount: '25ml',
        ),
        Ingredient(
          id: 'i20_5',
          name: 'Muối tinh hồng Himalaya',
          amount: '1/4 thìa cafe',
        ),
        Ingredient(id: 'i20_6', name: 'Đá viên mát lạnh', amount: '1 ly'),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Pha cốt cà phê phin truyền thống',
          description:
              'Ủ bột cà phê với nước sôi 95°C trong 2 phút rồi châm thêm nước sôi chiết xuất 50ml cốt cà phê đen sánh đậm đà.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Đánh bông lớp kem muối mặn béo',
          description:
              'Cho kem béo, sữa tươi và muối hồng vào ca đánh sữa. Dùng máy tạo bọt đánh đều 30-40 giây đến khi kem bông sánh mịn sệt như mây.',
          tip:
              'Không đánh kem quá cứng để lớp kem dễ dàng hòa quyện cùng cà phê khi uống.',
          durationMinutes: 3,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rót tầng cà phê & Phủ kem muối',
          description:
              'Khuấy đều cà phê đen cùng sữa đặc, cho đá viên vào ly. Nhẹ nhàng rót lớp kem muối bồng bềnh lên trên cùng, rắc một chút bột cacao trang trí.',
          durationMinutes: 2,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 21. Bánh Flan Caramel Mềm Mịn Cà Phê Đá
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_21',
      title: 'Bánh Flan Caramel Mềm Mịn Cà Phê Đá',
      category: 'Bánh ngọt',
      imageUrl:
          'https://images.unsplash.com/photo-1528975604071-b4dc52a2d18c?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Ngọt Thảo Vy',
      chefAvatar: '',
      rating: 4.93,
      reviewsCount: 410,
      cookTimeMinutes: 40,
      difficulty: 'Dễ',
      calories: 220,
      servings: 6,
      tags: ['#BánhFlan', '#Caramel', '#TrángMiệng', '#BánhNgọt', '#MềmMịn'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 7,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ingredients: [
        Ingredient(
          id: 'i21_1',
          name: 'Trứng gà tươi (lấy 4 quả + 2 lòng đỏ)',
          amount: '6 quả',
        ),
        Ingredient(
          id: 'i21_2',
          name: 'Sữa tươi không đường Dalat Milk',
          amount: '450ml',
        ),
        Ingredient(id: 'i21_3', name: 'Sữa đặc có đường', amount: '150g'),
        Ingredient(
          id: 'i21_4',
          name: 'Đường cát trắng thắng caramel',
          amount: '80g',
        ),
        Ingredient(
          id: 'i21_5',
          name: 'Tinh chất vani Pháp & nước cốt chanh',
          amount: '1 thìa cafe',
        ),
        Ingredient(
          id: 'i21_6',
          name: 'Cà phê đen đá & đá bào ăn kèm',
          amount: 'Tùy thích',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Thắng đường caramel hổ phách',
          description:
              'Đun đường cát cùng vài giọt nước cốt chanh trên lửa nhỏ đến khi chuyển màu hổ phách óng ánh. Nhanh tay tráng lớp mỏng vào đáy từng hũ flan.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Khuấy hỗn hợp trứng sữa mịn màng',
          description:
              'Khuấy tan sữa tươi cùng sữa đặc đun ấm nhẹ 50°C. Đánh tan trứng nhẹ tay một chiều, rót sữa vào trứng rồi lọc qua rây 2 lần để hỗn hợp mịn màng không bọt khí.',
          tip:
              'Khuấy nhẹ một chiều và lọc qua rây giúp bánh flan mịn màng tuyệt đối không bị rỗ mặt.',
          durationMinutes: 12,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Hấp cách thủy lửa nhỏ liu riu',
          description:
              'Rót trứng sữa vào hũ, bọc giấy bạc. Hấp cách thủy lửa nhỏ nhất trong 25-30 phút. Bánh để mát tủ lạnh, úp ra đĩa chan cà phê đá bào béo ngậy.',
          durationMinutes: 20,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 22. Ba Chỉ Bò Cuộn Nấm Kim Châm Sốt Tiêu Đen
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_22',
      title: 'Ba Chỉ Bò Cuộn Nấm Kim Châm Sốt Tiêu Đen',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Quang Huy',
      chefAvatar: '',
      rating: 4.86,
      reviewsCount: 230,
      cookTimeMinutes: 15,
      difficulty: 'Dễ',
      calories: 460,
      servings: 3,
      tags: ['#BòCuộnNấm', '#NhanhGọn', '#MónChính', '#ĐậmVị', '< 20 phút'],
      isFavorite: false,
      isSaved: true,
      cookedCount: 4,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(
          id: 'i22_1',
          name: 'Ba chỉ bò Mỹ thái dải mỏng',
          amount: '350g',
        ),
        Ingredient(
          id: 'i22_2',
          name: 'Nấm kim châm trắng giòn ngọt',
          amount: '2 gói',
        ),
        Ingredient(
          id: 'i22_3',
          name: 'Dầu hào, xì dầu, tương ớt',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i22_4',
          name: 'Tiêu đen xay vỡ & tỏi băm thơm',
          amount: '1 muỗng cafe',
        ),
        Ingredient(
          id: 'i22_5',
          name: 'Bơ lạt & hành lá chần buộc',
          amount: '1 muỗng canh',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Cuộn bò quanh nấm kim châm',
          description:
              'Rửa sạch nấm kim châm tách cụm nhỏ. Trải dải thịt ba chỉ bò ra thớt, đặt nấm vào giữa và cuộn chặt tay đều đặn.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Áp chảo bò cuộn nấm xém cạnh',
          description:
              'Cho chút bơ lạt vào chảo, áp chảo từng cuộn bò đến khi thịt xém cạnh vàng nâu và nấm chín tiết ra vị ngọt thanh.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rưới sốt tiêu đen sánh quyện',
          description:
              'Hòa dầu hào, xì dầu, tương ớt và tiêu đen vào chảo, đảo nhẹ 2 phút cho sốt bọc đều quanh từng cuộn bò bóng bẩy.',
          tip:
              'Không đun quá lâu để nấm kim châm giữ trọn độ giòn sần sật mọng nước.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 23. Sườn Xào Chua Ngọt Óng Ả Chuẩn Cơm Mẹ Nấu
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_23',
      title: 'Sườn Xào Chua Ngọt Óng Ả Chuẩn Cơm Mẹ Nấu',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
      chefName: 'Mẹ Bắp',
      chefAvatar: '',
      rating: 4.91,
      reviewsCount: 450,
      cookTimeMinutes: 30,
      difficulty: 'Trung bình',
      calories: 540,
      servings: 4,
      tags: ['#SườnXàoChuaNgọt', '#CơmGiaĐình', '#MónChính', '#ĐậmĐà'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 5,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 4)),
      ingredients: [
        Ingredient(
          id: 'i23_1',
          name: 'Sườn non heo dẻ nhỏ mềm thịt',
          amount: '600g',
        ),
        Ingredient(
          id: 'i23_2',
          name: 'Hành tây, ớt chuông đỏ xanh',
          amount: '1 củ',
        ),
        Ingredient(
          id: 'i23_3',
          name: 'Cốt sốt me hoặc giấm gạo thanh dịu',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i23_4',
          name: 'Tương cà chua ketchup & tương ớt',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i23_5',
          name: 'Đường mía, nước mắm ngon, tỏi băm',
          amount: '2 muỗng',
        ),
        Ingredient(
          id: 'i23_6',
          name: 'Hành hoa & mè trắng rang',
          amount: '20g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Chần sườn & Chiên vàng xém',
          description:
              'Chặt sườn khúc vừa ăn, chần qua nước sôi gừng. Chiên sườn trên chảo dầu nóng đến khi lớp thịt ngoài se lại vàng ươm.',
          tip:
              'Chiên sườn vàng mặt trước khi đảo sốt giúp thịt giữ trọn độ mọng nước bên trong.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Pha sốt chua ngọt tỷ lệ vàng',
          description:
              'Khuấy đều giấm gạo, đường, nước mắm, tương cà, tương ớt và chút nước lọc thành hỗn hợp sốt đỏ cam óng ánh.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rim sườn ngấm sốt sánh kẹo',
          description:
              'Phi thơm hành tỏi, trút sườn và nước sốt vào rim lửa nhỏ cho sốt keo lại bọc quanh từng miếng sườn. Thêm ớt chuông đảo nhanh 2 phút và rắc mè rang.',
          durationMinutes: 15,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 24. Salad Bơ Cá Ngừ Tươi Sốt Mayonnaise Chanh Vàng
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_24',
      title: 'Salad Bơ Cá Ngừ Tươi Sốt Mayonnaise Chanh Vàng',
      category: 'Eat Clean',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop&q=80',
      chefName: 'Linh Đan Healthy',
      chefAvatar: '',
      rating: 4.82,
      reviewsCount: 175,
      cookTimeMinutes: 12,
      difficulty: 'Dễ',
      calories: 290,
      servings: 2,
      tags: ['#SaladBơ', '#CáNgừ', '#EatClean', '#Healthy', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 8,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 14)),
      ingredients: [
        Ingredient(
          id: 'i24_1',
          name: 'Cá ngừ ngâm dầu ô liu đóng hộp',
          amount: '1 hộp',
        ),
        Ingredient(
          id: 'i24_2',
          name: 'Quả bơ sáp 034 chín tới dẻo thơm',
          amount: '1 trái',
        ),
        Ingredient(
          id: 'i24_3',
          name: 'Xà lách thuỷ canh & cà chua bi bi',
          amount: '150g',
        ),
        Ingredient(
          id: 'i24_4',
          name: 'Ngô ngọt hấp & dưa leo giòn mát',
          amount: '100g',
        ),
        Ingredient(
          id: 'i24_5',
          name: 'Sốt Mayonnaise ít béo & chanh vàng',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i24_6',
          name: 'Muối tiêu đen & dầu hạt lanh',
          amount: '1 thìa cafe',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Sơ chế rau củ tươi sạch',
          description:
              'Rau xà lách rửa sạch để ráo nước, cắt khúc vừa ăn. Cắt đôi cà chua bi, bơ sáp cắt khối vuông đẹp mắt.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Pha sốt mayonnaise chanh thanh mát',
          description:
              'Trộn sốt mayonnaise, nước cốt chanh vàng, muối tiêu đen và 1 thìa dầu ô liu thành hỗn hợp mịn màng thơm dịu.',
          durationMinutes: 3,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trộn đều salad & Thưởng thức',
          description:
              'Xếp rau củ ra tô, dầm cá ngừ đặt lên trên cùng các khối bơ sáp dẻo ngậy. Rưới sốt kem và trộn đều nhẹ tay khi ăn.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 25. Hủ Tiếu Nam Vang Tôm Mực Nước Lèo Trong Ngọt
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_25',
      title: 'Hủ Tiếu Nam Vang Tôm Mực Nước Lèo Trong Ngọt',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1594998893017-36147cbcae05?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chú Sáu Chợ Lớn',
      chefAvatar: '',
      rating: 4.89,
      reviewsCount: 360,
      cookTimeMinutes: 45,
      difficulty: 'Trung bình',
      calories: 510,
      servings: 4,
      tags: ['#HủTiếu', '#NamVang', '#TômMực', '#ChợLớn', '#MónNước'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 5)),
      ingredients: [
        Ingredient(
          id: 'i25_1',
          name: 'Hủ tiếu dai Sa Đéc chính gốc',
          amount: '500g',
        ),
        Ingredient(
          id: 'i25_2',
          name: 'Xương ống heo & mực khô nướng',
          amount: '1kg',
        ),
        Ingredient(
          id: 'i25_3',
          name: 'Tôm sú tươi lột vỏ chừa đuôi',
          amount: '300g',
        ),
        Ingredient(
          id: 'i25_4',
          name: 'Thịt băm xào tỏi & tim cật heo',
          amount: '250g',
        ),
        Ingredient(id: 'i25_5', name: 'Trứng cút luộc bóc vỏ', amount: '8 quả'),
        Ingredient(
          id: 'i25_6',
          name: 'Tỏi phi giòn tan ngập mỡ thơm',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i25_7',
          name: 'Cần tàu, hẹ lá, giá sống, cải cúc',
          amount: '200g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Hầm nước lèo trong veo ngọt tủy',
          description:
              'Hầm xương heo cùng khô mực nướng và tôm khô lửa riu riu trong 2-3 tiếng để nước lèo trong vắt ngọt thanh tự nhiên.',
          tip:
              'Mực khô nướng sơ trước khi thả vào hầm mang lại vị ngọt sâu lắng đặc trưng.',
          durationMinutes: 25,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Luộc tôm mực & Xào thịt băm tỏi phi',
          description:
              'Luộc tôm sú và tim cật vừa chín tới ngâm nước lạnh cho giòn. Xào thịt băm cùng tỏi phi vàng thơm lừng.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trần sợi hủ tiếu dai & Hoàn thiện',
          description:
              'Trần sợi hủ tiếu Sa Đéc vào tô, xếp tôm mực, thịt băm, trứng cút, cần tàu, rắc thật nhiều tỏi phi thơm và chan nước lèo nóng hổi.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 26. Gỏi Cuốn Tôm Thịt Chấm Sốt Tương Bơ Đậu Phộng
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_26',
      title: 'Gỏi Cuốn Tôm Thịt Chấm Sốt Tương Bơ Đậu Phộng',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Nhà Út',
      chefAvatar: '',
      rating: 4.94,
      reviewsCount: 480,
      cookTimeMinutes: 20,
      difficulty: 'Dễ',
      calories: 280,
      servings: 4,
      tags: ['#GỏiCuốn', '#TômThịt', '#ĂnVặt', '#ThanhĐạm', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 11,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 10)),
      ingredients: [
        Ingredient(
          id: 'i26_1',
          name: 'Bánh tráng dẻo cuốn gỏi không rách',
          amount: '1 xấp',
        ),
        Ingredient(
          id: 'i26_2',
          name: 'Tôm sú tươi luộc chẻ đôi dọc thân',
          amount: '300g',
        ),
        Ingredient(
          id: 'i26_3',
          name: 'Thịt ba chỉ luộc thái mỏng',
          amount: '250g',
        ),
        Ingredient(
          id: 'i26_4',
          name: 'Bún tươi sợi nhỏ thanh mát',
          amount: '300g',
        ),
        Ingredient(
          id: 'i26_5',
          name: 'Hẹ lá xanh dài, xà lách, rau thơm các loại',
          amount: '200g',
        ),
        Ingredient(
          id: 'i26_6',
          name: 'Tương đen Hoisin & bơ đậu phộng béo bùi',
          amount: '4 muỗng canh',
        ),
        Ingredient(
          id: 'i26_7',
          name: 'Đậu phộng rang giã nhỏ & ớt sa tế',
          amount: '30g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Luộc tôm thịt chín mọng',
          description:
              'Luộc tôm sú chín đỏ, bóc vỏ và chẻ đôi con tôm. Thịt ba chỉ luộc với củ hành tím cho thơm rồi thái mỏng đều.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Cuốn gỏi chặt tay đẹp mắt',
          description:
              'Thấm ướt nhẹ bánh tráng, xếp xà lách, bún tươi, thịt luộc. Đặt tôm mặt đỏ hướng ra ngoài cùng cọng hẹ thò đầu ra ngoài rồi cuộn tròn chặt tay.',
          tip:
              'Mặt tôm đỏ úp xuống bánh tráng giúp cuốn gỏi xong lộ màu đỏ cam rực rỡ.',
          durationMinutes: 7,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Nấu sốt tương bơ đậu phộng béo ngậy',
          description:
              'Phi thơm tỏi, cho tương Hoisin, bơ đậu phộng, chút nước cốt dừa và đường khuấy sệt lại. Múc ra chén rắc đậu phộng rang giòn chấm đẫm.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 27. Gà Nướng Muối Ớt Da Giòn Cháy Cạnh
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_27',
      title: 'Gà Nướng Muối Ớt Da Giòn Cháy Cạnh',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&auto=format&fit=crop&q=80',
      chefName: 'Vua Nướng Tây Bắc',
      chefAvatar: '',
      rating: 4.87,
      reviewsCount: 310,
      cookTimeMinutes: 45,
      difficulty: 'Trung bình',
      calories: 580,
      servings: 4,
      tags: ['#GàNướng', '#MuốiỚt', '#DaGiòn', '#TiệcNướng'],
      isFavorite: false,
      isSaved: true,
      cookedCount: 2,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 7)),
      ingredients: [
        Ingredient(
          id: 'i27_1',
          name: 'Gà ta thả vườn nguyên con làm sạch',
          amount: '1.4kg',
        ),
        Ingredient(
          id: 'i27_2',
          name: 'Muối hạt giã ớt hiểm đỏ cay xé lưỡi',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i27_3',
          name: 'Nước sốt mật ong & dầu màu điều quét da',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i27_4',
          name: 'Tỏi băm, hành khô, sả băm, hạt tiêu rừng',
          amount: '50g',
        ),
        Ingredient(
          id: 'i27_5',
          name: 'Muối tiêu chanh lá chanh ăn kèm',
          amount: '1 chén',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Phanh đôi gà & Ướp muối ớt',
          description:
              'Phanh đôi ức gà ép dẹt. Ướp bên trong thịt với hỗn hợp tỏi ớt, sả, hạt tiêu và một chút nước mắm cốt trong 30 phút.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nướng than hoa hoặc nồi chiên',
          description:
              'Nướng gà ở 180°C trong 30 phút cho chín đều từ trong ra ngoài.',
          durationMinutes: 25,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Quét sốt mật ong tạo da giòn rụm',
          description:
              'Quét lớp mật ong dầu điều muối ớt lên bề mặt da gà, nướng tiếp ở 200°C trong 10 phút đến khi da phồng rộp giòn tan thơm lừng.',
          tip:
              'Quét mật ong ở bước cuối cùng để da gà giòn óng mà không bị cháy khét.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 28. Trà Sữa Trân Châu Đường Đen Truyền Thống
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_28',
      title: 'Trà Sữa Trân Châu Đường Đen Truyền Thống',
      category: 'Đồ uống',
      imageUrl:
          'https://images.unsplash.com/photo-1558857563-b37fcbf19934?w=800&auto=format&fit=crop&q=80',
      chefName: 'Barista Vy Vy',
      chefAvatar: '',
      rating: 4.85,
      reviewsCount: 520,
      cookTimeMinutes: 20,
      difficulty: 'Dễ',
      calories: 360,
      servings: 2,
      tags: [
        '#TràSữa',
        '#TrânChâuĐườngĐen',
        '#ĐồUống',
        '#GiớiTrẻ',
        '< 20 phút',
      ],
      isFavorite: true,
      isSaved: true,
      cookedCount: 14,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ingredients: [
        Ingredient(
          id: 'i28_1',
          name: 'Trà đen Ceylon hoặc hồng trà Phúc Long',
          amount: '20g',
        ),
        Ingredient(
          id: 'i28_2',
          name: 'Sữa tươi thanh trùng Dalat Milk',
          amount: '300ml',
        ),
        Ingredient(
          id: 'i28_3',
          name: 'Bột béo thực vật tạo độ ngậy thơm',
          amount: '30g',
        ),
        Ingredient(
          id: 'i28_4',
          name: 'Trân châu đen dẻo dai hoàng kim',
          amount: '150g',
        ),
        Ingredient(
          id: 'i28_5',
          name: 'Đường đen Hàn Quốc (Dark Brown Sugar)',
          amount: '80g',
        ),
        Ingredient(id: 'i28_6', name: 'Đá viên mát lạnh', amount: '1 ly'),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ủ cốt hồng trà đậm vị',
          description:
              'Ủ hồng trà cùng 250ml nước sôi 95°C trong 12 phút. Lọc bỏ bã, hòa cùng bột béo và chút sữa đặc khuấy đều.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nấu trân châu rim đường đen keo chỉ',
          description:
              'Luộc trân châu chín dẻo mềm, xả qua nước ấm. Đun đường đen với chút nước đến khi sôi sủi bọt keo lại thì trút trân châu vào ngâm ấm 15 phút.',
          tip:
              'Đường đen sánh dẻo bám quanh thành ly tạo hiệu ứng vân hổ cực bắt mắt.',
          durationMinutes: 7,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trình bày ly trà sữa vân hổ',
          description:
              'Múc trân châu đường đen tráng quanh thành ly, thêm đá viên đầy ly rồi rót trà sữa thơm lừng lên trên và cắm ống hút thưởng thức.',
          durationMinutes: 3,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 29. Nem Lụi Nướng Sả Nước Lèo Bùi Béo
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_29',
      title: 'Nem Lụi Nướng Sả Nước Lèo Bùi Béo',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop&q=80',
      chefName: 'O Lan Xứ Quảng',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 290,
      cookTimeMinutes: 35,
      difficulty: 'Trung bình',
      calories: 470,
      servings: 4,
      tags: ['#NemLụi', '#NướngSả', '#ĐặcSảnHuế', '#ĂnVặt'],
      isFavorite: false,
      isSaved: true,
      cookedCount: 1,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 8)),
      ingredients: [
        Ingredient(id: 'i29_1', name: 'Giò sống heo dẻo quánh', amount: '400g'),
        Ingredient(
          id: 'i29_2',
          name: 'Thịt mỡ heo thái hạt lựu luộc đường',
          amount: '150g',
        ),
        Ingredient(
          id: 'i29_3',
          name: 'Cây sả tươi thân mập mạp',
          amount: '12 cây',
        ),
        Ingredient(
          id: 'i29_4',
          name: 'Gan heo tươi & bơ đậu phộng nấu sốt lèo',
          amount: '150g',
        ),
        Ingredient(
          id: 'i29_5',
          name: 'Bánh tráng cuốn, dưa leo, chuối chát, khế chua',
          amount: '200g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Quết nem dẻo dai bọc cây sả',
          description:
              'Quết giò sống cùng thịt mỡ, hạt tiêu, tỏi băm đến khi thật dẻo dai. Nắm hỗn hợp thịt bọc đều quanh gốc từng cây sả.',
          durationMinutes: 12,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nướng nem lụi vàng ruộm trên than',
          description:
              'Đặt các xiên nem lụi lên bếp nướng, quét một lớp mỡ hành nướng đều tay đến khi nem chín xém thơm phức mùi tinh dầu sả.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Nấu nước lèo gan bùi ngậy chấm nem',
          description:
              'Xay nhuyễn gan heo xào thơm cùng tương đậu, bơ đậu phộng nêm đường mắm sánh mịn. Cuốn nem cùng rau sống khế chua chấm nước lèo béo ngậy.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 30. Bánh Tráng Nướng Đà Lạt Trứng Cút Phô Mai
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_30',
      title: 'Bánh Tráng Nướng Đà Lạt Trứng Cút Phô Mai',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
      chefName: 'Cô Bảy Đà Lạt',
      chefAvatar: '',
      rating: 4.89,
      reviewsCount: 380,
      cookTimeMinutes: 12,
      difficulty: 'Dễ',
      calories: 320,
      servings: 2,
      tags: [
        '#BánhTrángNướng',
        '#ĐàLạt',
        '#ĂnVặt',
        '#PizzaViệtNam',
        '< 20 phút',
      ],
      isFavorite: true,
      isSaved: true,
      cookedCount: 15,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ingredients: [
        Ingredient(
          id: 'i30_1',
          name: 'Bánh tráng tròn loại mỏng nướng giòn',
          amount: '4 cái',
        ),
        Ingredient(id: 'i30_2', name: 'Trứng cút tươi', amount: '8 quả'),
        Ingredient(id: 'i30_3', name: 'Bò khô xé sợi cay ngọt', amount: '50g'),
        Ingredient(
          id: 'i30_4',
          name: 'Tép sấy đỏ giòn & hành lá mỡ băm nhuyễn',
          amount: '40g',
        ),
        Ingredient(
          id: 'i30_5',
          name: 'Phô mai tam giác Con Bò Cười',
          amount: '2 viên',
        ),
        Ingredient(
          id: 'i30_6',
          name: 'Tương ớt cay & sốt Mayonnaise',
          amount: '2 muỗng',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nướng nóng bánh tráng & Thoa bơ',
          description:
              'Đặt bánh tráng lên vỉ than hồng hoặc chảo chống dính khô ráo. Thoa một chút bơ lạt và hành lá thái nhỏ.',
          durationMinutes: 3,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Đập trứng cút & Tán đều phô mai',
          description:
              'Đập 2 quả trứng cút và 1/2 viên phô mai lên mặt bánh, dùng thìa tán đều khắp mặt bánh tráng trên lửa nhỏ cho trứng se lại chín vàng.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rắc topping tép khô bò & Gập đôi',
          description:
              'Rắc tép sấy, khô bò xé sợi, xúc xích lát, xịt tương ớt và sốt mayonnaise. Khi đế bánh giòn rụm thì gấp đôi lại và thưởng thức nóng hổi.',
          tip: 'Để lửa thật nhỏ để đế bánh không bị cháy trước khi trứng chín.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 31. Đậu Hũ Non Sốt Nấm Đông Cô Hạt Sen Chay
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_31',
      title: 'Đậu Hũ Non Sốt Nấm Đông Cô Hạt Sen Chay',
      category: 'Món chay',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
      chefName: 'An Nhiên Bếp Chay',
      chefAvatar: '',
      rating: 4.86,
      reviewsCount: 190,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 260,
      servings: 3,
      tags: ['#MónChay', '#ĐậuHũNon', '#NấmĐôngCô', '#ThanhTịnh', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 4,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i31_1',
          name: 'Đậu hũ non cây mềm mịn Ichiban',
          amount: '2 cây',
        ),
        Ingredient(
          id: 'i31_2',
          name: 'Nấm đông cô tươi khía hoa',
          amount: '150g',
        ),
        Ingredient(
          id: 'i31_3',
          name: 'Hạt sen tươi luộc chín bở',
          amount: '80g',
        ),
        Ingredient(
          id: 'i31_4',
          name: 'Dầu hào chay từ nấm & xì dầu thanh vị',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i31_5',
          name: 'Bột bắp tạo độ sánh & ngò rí tươi',
          amount: '1 muỗng cafe',
        ),
        Ingredient(
          id: 'i31_6',
          name: 'Dầu mè thơm & tiêu trắng xay',
          amount: '1 thìa cafe',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Cắt khoanh & Hấp nóng đậu hũ non',
          description:
              'Cắt đậu hũ non thành từng khoanh dày 2cm. Xếp ra đĩa sâu lòng, hấp cách thủy 5 phút cho nóng ấm.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nấu sốt nấm đông cô hạt sen sánh mịn',
          description:
              'Phi thơm hành bo-rô, cho nấm đông cô và hạt sen vào xào thơm. Thêm dầu hào chay, xì dầu, nước lọc và bột bắp hòa tan đun sôi sền sệt.',
          tip:
              'Dùng hành bo-rô (tỏi tây) phi thơm tạo vị ngọt thơm thanh tịnh chuẩn chay.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rưới sốt nấm lên đĩa đậu hũ',
          description:
              'Nhẹ nhàng rưới nước sốt nấm hạt sen óng ả lên trên đĩa đậu hũ non, rắc tiêu trắng và vài nhánh ngò rí thưởng thức cùng cơm nóng.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 32. Cơm Gạo Lứt Ức Gà Nướng Sốt Teriyaki Rau Củ
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_32',
      title: 'Cơm Gạo Lứt Ức Gà Nướng Sốt Teriyaki Rau Củ',
      category: 'Eat Clean',
      imageUrl:
          'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=800&auto=format&fit=crop&q=80',
      chefName: 'Fit & Healthy Kitchen',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 310,
      cookTimeMinutes: 20,
      difficulty: 'Dễ',
      calories: 390,
      servings: 2,
      tags: [
        '#EatClean',
        '#CơmGạoLứt',
        '#ỨcGàTeriyaki',
        '#GiữDáng',
        '< 20 phút',
      ],
      isFavorite: true,
      isSaved: true,
      cookedCount: 7,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 16)),
      ingredients: [
        Ingredient(
          id: 'i32_1',
          name: 'Cơm gạo lứt huyết rồng dẻo thơm',
          amount: '1 bát tô',
        ),
        Ingredient(
          id: 'i32_2',
          name: 'Ức gà phi lê khía mắt lưới',
          amount: '300g',
        ),
        Ingredient(
          id: 'i32_3',
          name: 'Súp lơ xanh (bông cải) & cà rốt luộc',
          amount: '150g',
        ),
        Ingredient(
          id: 'i32_4',
          name: 'Sốt Teriyaki Nhật Bản ít đường',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i32_5',
          name: 'Mè trắng rang thơm & dầu mè',
          amount: '1 thìa cafe',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ướp ức gà sốt Teriyaki',
          description:
              'Khía nhẹ mặt thịt ức gà, ướp cùng 2 muỗng sốt Teriyaki và tỏi băm trong 10 phút.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Áp chảo ức gà vàng nâu mọng sốt',
          description:
              'Áp chảo ức gà lửa vừa mỗi mặt 4-5 phút đến khi chín tới, rưới thêm phần sốt Teriyaki cho keo lại óng ả.',
          durationMinutes: 9,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Bày đĩa Eat Clean đầy đủ dưỡng chất',
          description:
              'Xới cơm gạo lứt ra đĩa, thái ức gà lát xéo đặt cạnh súp lơ luộc xanh mướt, rắc mè rang thơm phức lên trên.',
          durationMinutes: 6,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 33. Canh Rong Biển Thịt Bò Thanh Nhiệt Hàn Quốc
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_33',
      title: 'Canh Rong Biển Thịt Bò Thanh Nhiệt Hàn Quốc',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&auto=format&fit=crop&q=80',
      chefName: 'Oppa Kim Kitchen',
      chefAvatar: '',
      rating: 4.83,
      reviewsCount: 220,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 210,
      servings: 3,
      tags: [
        '#CanhRongBiển',
        '#ThịtBò',
        '#HànQuốc',
        '#ThanhNhiệt',
        '< 20 phút',
      ],
      isFavorite: false,
      isSaved: true,
      cookedCount: 5,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(
          id: 'i33_1',
          name: 'Rong biển khô nấu canh Miyeok',
          amount: '20g',
        ),
        Ingredient(
          id: 'i33_2',
          name: 'Thịt thăn bò tươi thái lát mỏng',
          amount: '150g',
        ),
        Ingredient(
          id: 'i33_3',
          name: 'Dầu mè nguyên chất thơm nồng',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i33_4',
          name: 'Tỏi băm nhuyễn & nước tương Ganjang',
          amount: '2 muỗng',
        ),
        Ingredient(
          id: 'i33_5',
          name: 'Hạt nêm xương hầm & tiêu xay',
          amount: '1 thìa cafe',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ngâm nở rong biển & Thái khúc',
          description:
              'Ngâm rong biển trong nước lạnh 10 phút cho nở mềm gấp 5 lần. Rửa sạch, bóp ráo nước và cắt khúc vừa ăn.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào thơm thịt bò cùng dầu mè',
          description:
              'Phi thơm tỏi băm với dầu mè, cho thịt bò vào đảo chín tái rồi trút rong biển vào xào chung trong 3 phút cho ngấm vị dầu mè thơm ngậy.',
          tip:
              'Xào kỹ rong biển với dầu mè giúp khử hoàn toàn vị tanh của rong biển.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Nấu nước canh ngọt thanh',
          description:
              'Đổ 800ml nước lọc vào đun sôi bùng, nêm nước tương Hàn Quốc và chút hạt nêm, hạ lửa nhỏ nấu thêm 7 phút cho canh ngọt đậm đà.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 34. Bánh Tiramisu Ý Cà Phê Mascarpone Cacao
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_34',
      title: 'Bánh Tiramisu Ý Cà Phê Mascarpone Cacao',
      category: 'Bánh ngọt',
      imageUrl:
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Giovanni Hải',
      chefAvatar: '',
      rating: 4.95,
      reviewsCount: 380,
      cookTimeMinutes: 30,
      difficulty: 'Trung bình',
      calories: 340,
      servings: 6,
      tags: ['#Tiramisu', '#NướcÝ', '#Mascarpone', '#BánhNgọt', '#KhôngCầnLò'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i34_1',
          name: 'Phô mai Mascarpone Tatua mềm mịn',
          amount: '250g',
        ),
        Ingredient(
          id: 'i34_2',
          name: 'Bánh sâm-panh Savoiardi (Ladyfingers)',
          amount: '1 gói',
        ),
        Ingredient(
          id: 'i34_3',
          name: 'Kem tươi Whipping cream Anchor',
          amount: '200ml',
        ),
        Ingredient(
          id: 'i34_4',
          name: 'Cà phê Espresso đen nguyên chất đậm đặc',
          amount: '150ml',
        ),
        Ingredient(
          id: 'i34_5',
          name: 'Rượu Rhum thơm lừng & đường bột',
          amount: '30ml',
        ),
        Ingredient(
          id: 'i34_6',
          name: 'Bột Cacao nguyên chất rắc mặt bánh',
          amount: '20g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Đánh kem phô mai Mascarpone bồng bềnh',
          description:
              'Đánh bông whipping cream với đường bột. Tán nhuyễn mascarpone rồi fold nhẹ nhàng cùng kem tươi đến khi thu được hỗn hợp mượt mà không tách nước.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nhúng bánh Savoiardi vào cà phê Rhum',
          description:
              'Hòa cà phê espresso đậm đà cùng rượu Rhum. Nhúng nhanh hai mặt bánh sâm-panh trong 1 giây rồi xếp ngay ngắn vào đáy khuôn.',
          tip:
              'Chỉ nhúng bánh đúng 1 giây để bánh hút vừa đủ cà phê mà không bị nhũn nát.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Xếp tầng & Phủ bột cacao nguyên chất',
          description:
              'Trải một lớp kem mascarpone lên bánh, lặp lại thêm một lớp bánh và kem. Để tủ lạnh ít nhất 4 tiếng, trước khi ăn rây bột cacao phủ kín mặt bánh.',
          durationMinutes: 12,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 35. Trà Mãng Cầu Xiêm Tươi Đắk Lắk Thanh Mát
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_35',
      title: 'Trà Mãng Cầu Xiêm Tươi Đắk Lắk Thanh Mát',
      category: 'Đồ uống',
      imageUrl:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800&auto=format&fit=crop&q=80',
      chefName: 'Barista Vy Vy',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 460,
      cookTimeMinutes: 12,
      difficulty: 'Dễ',
      calories: 160,
      servings: 2,
      tags: ['#TràMãngCầu', '#ĐắkLắk', '#HotTrend', '#ĐồUống', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 16,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ingredients: [
        Ingredient(
          id: 'i35_1',
          name: 'Trà lài (trà hoa nhài) thơm dịu',
          amount: '15g',
        ),
        Ingredient(
          id: 'i35_2',
          name: 'Thịt mãng cầu xiêm tươi tách hạt ngâm đường',
          amount: '150g',
        ),
        Ingredient(
          id: 'i35_3',
          name: 'Nước cốt tắc (quất) tươi chua thanh',
          amount: '2 muỗng cafe',
        ),
        Ingredient(
          id: 'i35_4',
          name: 'Nước đường phèn hoa quả',
          amount: '30ml',
        ),
        Ingredient(id: 'i35_5', name: 'Đá viên tinh khiết', amount: '1 ly lớn'),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ủ cốt trà lài thơm hương hoa',
          description:
              'Ủ trà lài cùng 200ml nước sôi 85°C trong 8 phút rồi lọc lấy cốt trà thơm thanh dịu.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Lắc trà cùng mãng cầu xiêm mọng nước',
          description:
              'Cho cốt trà lài, thịt mãng cầu ngâm đường, nước tắc tươi, nước đường phèn và đá viên vào shaker lắc mạnh 15 giây.',
          durationMinutes: 4,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rót ly & Thưởng thức chua ngọt giòn tép',
          description:
              'Rót trà ra ly lớn, múc thêm 2 thìa thịt mãng cầu tươi lên trên mặt ly, cắm ống hút to thưởng thức từng ngụm mát lạnh đã khát.',
          durationMinutes: 3,
        ),
      ],
    ),
    ...getAdditionalRecipesPart2(),
  ];
}

List<RecipeCollection> getInitialCollections() {
  return [
    RecipeCollection(
      id: 'col_1',
      name: 'Món Eat Clean & Healthy Dáng Xinh',
      description:
          'Tổng hợp các món giàu protein, ít calo cho thực đơn giữ dáng',
      coverImageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFF2A9D8F,
      recipeIds: ['rec_2', 'rec_16', 'rec_24', 'rec_32', 'rec_33', 'rec_60'],
    ),
    RecipeCollection(
      id: 'col_2',
      name: 'Mâm Cơm Gia Đình Chuẩn Vị Việt',
      description: 'Những món mặn canh ngọt đậm đà hương vị quê hương ấm cúng',
      coverImageUrl:
          'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFFE76F51,
      recipeIds: [
        'rec_1',
        'rec_3',
        'rec_4',
        'rec_6',
        'rec_8',
        'rec_17',
        'rec_18',
        'rec_23',
        'rec_37',
        'rec_39',
        'rec_44',
        'rec_47',
        'rec_48',
        'rec_49',
        'rec_50',
        'rec_54',
      ],
    ),
    RecipeCollection(
      id: 'col_3',
      name: 'Bữa Tối Nhanh Gọn < 20 Phút',
      description: 'Món ngon siêu tốc tiện lợi cho ngày dài bận rộn',
      coverImageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFF457B9D,
      recipeIds: [
        'rec_2',
        'rec_5',
        'rec_14',
        'rec_16',
        'rec_20',
        'rec_22',
        'rec_24',
        'rec_26',
        'rec_28',
        'rec_30',
        'rec_31',
        'rec_32',
        'rec_33',
        'rec_35',
        'rec_40',
        'rec_42',
        'rec_47',
        'rec_48',
        'rec_51',
        'rec_53',
        'rec_55',
        'rec_57',
        'rec_58',
        'rec_60',
        'rec_61',
        'rec_62',
        'rec_64',
        'rec_66',
        'rec_67',
        'rec_68',
        'rec_69',
      ],
    ),
    RecipeCollection(
      id: 'col_4',
      name: 'Tiệm Bánh & Tráng Miệng Ngọt Ngào',
      description: 'Công thức làm bánh nướng, bánh ngọt và đồ uống mát lạnh',
      coverImageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFF9C27B0,
      recipeIds: [
        'rec_5',
        'rec_7',
        'rec_20',
        'rec_21',
        'rec_28',
        'rec_34',
        'rec_35',
        'rec_68',
        'rec_69',
        'rec_70',
      ],
    ),
    RecipeCollection(
      id: 'col_5',
      name: 'Đặc Sản Ẩm Thực 3 Miền Việt Nam',
      description:
          'Tinh hoa bún, phở, cơm tấm, bánh xèo chuẩn phong vị Bắc - Trung - Nam',
      coverImageUrl:
          'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFFE63946,
      recipeIds: [
        'rec_1',
        'rec_4',
        'rec_8',
        'rec_9',
        'rec_10',
        'rec_11',
        'rec_15',
        'rec_17',
        'rec_18',
        'rec_19',
        'rec_25',
        'rec_36',
        'rec_37',
        'rec_38',
        'rec_39',
        'rec_41',
        'rec_42',
        'rec_43',
        'rec_44',
        'rec_45',
        'rec_46',
        'rec_50',
        'rec_52',
        'rec_54',
      ],
    ),
    RecipeCollection(
      id: 'col_6',
      name: 'Thiên Đường Món Nước & Bún Phở',
      description: 'Những tô nước dùng ngọt thanh, bốc khói nghi ngút ấm lòng',
      coverImageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFFF4A261,
      recipeIds: [
        'rec_1',
        'rec_9',
        'rec_12',
        'rec_15',
        'rec_18',
        'rec_19',
        'rec_25',
        'rec_33',
        'rec_36',
        'rec_38',
        'rec_41',
        'rec_42',
        'rec_45',
        'rec_50',
        'rec_56',
        'rec_63',
      ],
    ),
    RecipeCollection(
      id: 'col_7',
      name: 'Ăn Vặt & Món Cuốn Đường Phố Giòn Rụm',
      description:
          'Món ăn vặt thơm lừng, cuốn bánh tráng chấm sốt đậm đà gây nghiện',
      coverImageUrl:
          'https://images.unsplash.com/photo-1627308595229-7830a5c91f9f?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFF2A9D8F,
      recipeIds: [
        'rec_10',
        'rec_11',
        'rec_14',
        'rec_26',
        'rec_29',
        'rec_30',
        'rec_40',
        'rec_43',
        'rec_51',
        'rec_52',
        'rec_53',
        'rec_59',
      ],
    ),
    RecipeCollection(
      id: 'col_8',
      name: 'Bếp Chay Thanh Tịnh & Tốt Cho Sức Khỏe',
      description:
          'Các món chay rau củ nấm thanh đạm, giàu dinh dưỡng và an lành',
      coverImageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFF588157,
      recipeIds: ['rec_31', 'rec_55', 'rec_56', 'rec_57', 'rec_58', 'rec_59'],
    ),
    RecipeCollection(
      id: 'col_9',
      name: 'Ẩm Thực Quốc Tế & Món Âu - Á Hiện Đại',
      description:
          'Hương vị tinh hoa từ Hàn Quốc, Nhật Bản, Thái Lan và phong cách ẩm thực Âu',
      coverImageUrl:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFF3A86FF,
      recipeIds: [
        'rec_13',
        'rec_33',
        'rec_60',
        'rec_61',
        'rec_62',
        'rec_63',
        'rec_64',
        'rec_65',
        'rec_66',
        'rec_67',
      ],
    ),
    RecipeCollection(
      id: 'col_10',
      name: 'Quán Chè & Đồ Uống Mát Lạnh Giải Nhiệt',
      description:
          'Trà trái cây nhiệt đới, cà phê đặc sản và các món chè ngọt mát',
      coverImageUrl:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFFFF006E,
      recipeIds: ['rec_5', 'rec_20', 'rec_28', 'rec_35', 'rec_68', 'rec_69'],
    ),
    RecipeCollection(
      id: 'col_11',
      name: 'Hải Sản Tươi Ngon & Lẩu Nướng Cuối Tuần',
      description:
          'Món ốc, tôm mực đậm vị biển và những bữa tiệc nướng lẩu sum vầy',
      coverImageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=600&auto=format&fit=crop&q=80',
      colorValue: 0xFFFB5607,
      recipeIds: [
        'rec_6',
        'rec_12',
        'rec_16',
        'rec_27',
        'rec_36',
        'rec_38',
        'rec_40',
        'rec_45',
        'rec_46',
        'rec_48',
        'rec_64',
      ],
    ),
  ];
}

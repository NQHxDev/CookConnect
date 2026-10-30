import 'package:cookconnect/features/recipe/data/models/recipe.dart';

List<Recipe> getAdditionalRecipesPart2() {
  return [
    // -------------------------------------------------------------------------
    // 36. Bánh Canh Cua Bột Lọc Giò Heo Nước Dùng Sệt
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_36',
      title: 'Bánh Canh Cua Bột Lọc Giò Heo Nước Dùng Sệt',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1594998893017-36147cbcae05?w=800&auto=format&fit=crop&q=80',
      chefName: 'Má Ba Chợ Lớn',
      chefAvatar: '',
      rating: 4.93,
      reviewsCount: 410,
      cookTimeMinutes: 40,
      difficulty: 'Trung bình',
      calories: 560,
      servings: 4,
      tags: ['#BánhCanhCua', '#BộtLọc', '#GiòHeo', '#MónNước', '#SàiGòn'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 5,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 9)),
      ingredients: [
        Ingredient(
          id: 'i36_1',
          name: 'Sợi bánh canh bột lọc dai trong',
          amount: '500g',
        ),
        Ingredient(
          id: 'i36_2',
          name: 'Thịt cua biển Cà Mau gỡ sẵn tươi ngọt',
          amount: '250g',
        ),
        Ingredient(
          id: 'i36_3',
          name: 'Khoanh giò gân heo hầm mềm',
          amount: '400g',
        ),
        Ingredient(
          id: 'i36_4',
          name: 'Chả cua hấp & huyết heo luộc',
          amount: '200g',
        ),
        Ingredient(
          id: 'i36_5',
          name: 'Trứng cút bóc vỏ & nấm rơm búp',
          amount: '12 quả',
        ),
        Ingredient(
          id: 'i36_6',
          name: 'Bột năng pha loãng tạo độ sánh sệt',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i36_7',
          name: 'Hành hoa, ngò rí, tiêu sọ xay, ớt băm',
          amount: 'Vừa đủ',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Hầm nước dùng giò heo & Nấm rơm',
          description:
              'Hầm khoanh giò heo cùng hành tím nướng lửa nhỏ trong 30 phút cho giò mềm rục và nước ngọt thanh. Thả nấm rơm xào sơ vào nồi.',
          tip:
              'Xào nấm rơm với chút hành phi trước khi cho vào nồi nước dùng giúp nấm thơm béo và nước lèo dậy vị.',
          durationMinutes: 20,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào thịt cua màu điều & Tạo độ sánh',
          description:
              'Xào thịt cua biển cùng dầu hạt điều cho màu đỏ cam óng ả. Đổ nước bột năng pha loãng vào nồi nước lèo khuấy đều tay đến khi nước sánh sệt bóng bẩy.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trần bánh canh & Hoàn tất tô cua đậm đà',
          description:
              'Trần sợi bánh canh bột lọc vào tô, xếp giò heo, thịt cua xào, chả cua, trứng cút, rắc ngò gai hành hoa và chan nước lèo sánh đỏ nóng hổi.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 37. Cơm Gà Hội An Xé Phay Trộn Hành Tây Rau Răm
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_37',
      title: 'Cơm Gà Hội An Xé Phay Trộn Hành Tây Rau Răm',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Phố Cổ Hội An',
      chefAvatar: '',
      rating: 4.96,
      reviewsCount: 580,
      cookTimeMinutes: 35,
      difficulty: 'Trung bình',
      calories: 590,
      servings: 4,
      tags: ['#CơmGà', '#HộiAn', '#ĐặcSản', '#GàXéPhay', '#MónChính'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 6,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ingredients: [
        Ingredient(
          id: 'i37_1',
          name: 'Gà ta thả vườn luộc giòn da',
          amount: '1.2kg',
        ),
        Ingredient(
          id: 'i37_2',
          name: 'Gạo tẻ thơm nấu cùng nước luộc gà & nghệ',
          amount: '400g',
        ),
        Ingredient(
          id: 'i37_3',
          name: 'Hành tây trắng thái mỏng ngâm đá giòn',
          amount: '2 củ',
        ),
        Ingredient(
          id: 'i37_4',
          name: 'Rau răm tươi thái nhỏ thơm nồng',
          amount: '1 nắm lớn',
        ),
        Ingredient(
          id: 'i37_5',
          name: 'Nước cốt chanh, nước mắm ngon, tiêu sọ, đường',
          amount: 'Vừa đủ',
        ),
        Ingredient(
          id: 'i37_6',
          name: 'Tương ớt Hội An ngọt cay cay nồng',
          amount: '3 muỗng canh',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Luộc gà ta & Nấu cơm vàng ươm',
          description:
              'Luộc gà cùng gừng hành tím và chút bột nghệ cho da vàng rực. Lấy nước luộc gà nấu cơm cho hạt cơm căng bóng dẻo thơm ngậy mùi mỡ gà.',
          tip:
              'Rang gạo khô với mỡ gà trước khi nấu để từng hạt cơm tơi xốp bóng bẩy.',
          durationMinutes: 20,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xé phay thịt gà & Trộn gỏi hành tây',
          description:
              'Xé thịt gà thành miếng dài vừa ăn. Trộn đều thịt gà cùng hành tây ngâm giòn, rau răm, nước cốt chanh, nước mắm nhĩ và tiêu sọ thơm lừng.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Đơm cơm gà & Ăn kèm tương ớt phố cổ',
          description:
              'Xới cơm vàng ra đĩa, đặt gỏi gà xé phay lên trên, rưới chút tương ớt rim Hội An cay ngọt và dùng kèm bát canh lòng gà nóng hổi.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 38. Bún Chả Cá Quy Nhơn Nước Dùng Ngọt Thanh
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_38',
      title: 'Bún Chả Cá Quy Nhơn Nước Dùng Ngọt Thanh',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
      chefName: 'Cô Bảy Miền Trung',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 320,
      cookTimeMinutes: 30,
      difficulty: 'Dễ',
      calories: 470,
      servings: 4,
      tags: ['#BúnChảCá', '#QuyNhơn', '#ĐặcSảnBiển', '#ThanhNgọt', '#MónNước'],
      isFavorite: false,
      isSaved: true,
      cookedCount: 2,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(
          id: 'i38_1',
          name: 'Chả cá thu Quy Nhơn chiên vàng & hấp',
          amount: '400g',
        ),
        Ingredient(id: 'i38_2', name: 'Bún tươi sợi nhỏ', amount: '600g'),
        Ingredient(
          id: 'i38_3',
          name: 'Đầu xương cá thu hoặc cá cờ hầm lấy nước',
          amount: '500g',
        ),
        Ingredient(
          id: 'i38_4',
          name: 'Thơm (dứa) chín & cà chua chín mọng',
          amount: '1 trái',
        ),
        Ingredient(
          id: 'i38_5',
          name: 'Măng tươi xé sợi luộc kỹ',
          amount: '150g',
        ),
        Ingredient(
          id: 'i38_6',
          name: 'Hành hoa, ngò rí, ớt sim xanh ngâm mắm',
          amount: 'Vừa đủ',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nấu nước dùng cá ngọt thanh không tanh',
          description:
              'Nướng sơ đầu cá thu rồi hầm cùng thơm cắt lát và hành tím nướng. Lọc lấy nước lèo trong vắt ngọt lịm từ tủy cá.',
          tip:
              'Thơm (dứa) nấu cùng đầu cá giúp nước dùng trong và khử sạch hoàn toàn mùi tanh.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Thả cà chua, măng tươi & Chả cá lát',
          description:
              'Cho cà chua bổ múi cau, măng tươi xé sợi và chả cá thu cắt lát chéo vào nồi nước lèo đun sôi lăn tăn, nêm mắm nhĩ đậm đà.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trình bày tô bún chả cá xứ biển',
          description:
              'Xếp bún vào tô, múc chả cá chiên, chả cá hấp, cà chua, chan nước dùng trong veo và ăn kèm đĩa rau sống xanh mướt cùng chén ớt sim cay nồng.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 39. Chả Cá Lã Vọng Hà Nội Thì Là Đầu Hành
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_39',
      title: 'Chả Cá Lã Vọng Hà Nội Thì Là Đầu Hành',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Hoàng Nam',
      chefAvatar: '',
      rating: 4.97,
      reviewsCount: 650,
      cookTimeMinutes: 25,
      difficulty: 'Trung bình',
      calories: 540,
      servings: 3,
      tags: ['#ChảCáLãVọng', '#HàNội', '#ThìLà', '#MónChính', '#PhốCổ'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 4,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i39_1',
          name: 'Phi lê cá lăng sông tươi thái miếng dày',
          amount: '500g',
        ),
        Ingredient(
          id: 'i39_2',
          name: 'Riềng giã nát, mẻ ngấu, nghệ tươi, mắm tôm',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i39_3',
          name: 'Rau thì là tươi & đầu hành hoa chẻ sợi',
          amount: '300g',
        ),
        Ingredient(
          id: 'i39_4',
          name: 'Bún tươi sợi nhỏ & đậu phộng rang giòn',
          amount: '400g',
        ),
        Ingredient(
          id: 'i39_5',
          name: 'Mắm tôm thơm sủi bọt quất ớt & mỡ nước',
          amount: '1 chén',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ướp cá lăng cùng riềng mẻ nghệ',
          description:
              'Ướp miếng cá lăng cùng nước cốt riềng, mẻ ngấu lọc mịn, mắm tôm ngon và dầu nghệ trong 30 phút cho ngấm vàng đều.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nướng sơ cá trên than hoa',
          description:
              'Kẹp miếng cá lăng vào vỉ nướng trên than hồng cho se vàng hai mặt và dậy mùi thơm nức mũi.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Đảo chả cá xèo xèo cùng thì là tại bàn',
          description:
              'Đun chảo mỡ nóng, trút cá đã nướng vào đảo nhẹ cùng núi thì là và đầu hành hoa chẻ. Gắp cá ăn kèm bún, đậu phộng và chấm ngập mắm tôm đánh bông.',
          tip:
              'Ăn nóng trực tiếp trên chảo để giữ trọn độ ngậy thơm béo bùi của cá lăng.',
          durationMinutes: 7,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 40. Ốc Hương Xào Bơ Tỏi Bánh Mì Nóng Giòn
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_40',
      title: 'Ốc Hương Xào Bơ Tỏi Bánh Mì Nóng Giòn',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Tony Hùng',
      chefAvatar: '',
      rating: 4.91,
      reviewsCount: 430,
      cookTimeMinutes: 15,
      difficulty: 'Dễ',
      calories: 380,
      servings: 2,
      tags: ['#ỐcHương', '#BơTỏi', '#ĂnVặt', '#HảiSản', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 7,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 15)),
      ingredients: [
        Ingredient(
          id: 'i40_1',
          name: 'Ốc hương sống tươi rói giòn sần sật',
          amount: '400g',
        ),
        Ingredient(id: 'i40_2', name: 'Bơ lạt thơm lừng Anchor', amount: '50g'),
        Ingredient(
          id: 'i40_3',
          name: 'Tỏi băm ngập tràn phi vàng thơm',
          amount: '5 củ',
        ),
        Ingredient(
          id: 'i40_4',
          name: 'Ớt sừng băm nhuyễn & rau răm tươi',
          amount: '30g',
        ),
        Ingredient(
          id: 'i40_5',
          name: 'Đường cát vàng, hạt nêm, nước mắm',
          amount: '1 muỗng',
        ),
        Ingredient(
          id: 'i40_6',
          name: 'Bánh mì baguette nướng giòn rụm',
          amount: '2 ổ',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ngâm sạch & Luộc sơ ốc hương',
          description:
              'Ngâm ốc hương với ớt cay nhả sạch cát. Luộc sơ trong nước sôi cùng nhánh sả đập dập 2 phút rồi vớt ra ráo nước.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Làm sốt bơ tỏi vàng ruộm óng ánh',
          description:
              'Đun chảy bơ lạt, cho lượng tỏi băm khổng lồ vào phi thơm vàng se se. Nêm chút nước mắm, đường và tiêu đen cho đậm đà sền sệt.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Đảo ốc hương bọc sốt bơ tỏi',
          description:
              'Trút ốc hương vào chảo bơ tỏi đảo nhanh tay trên lửa lớn 3 phút cho sốt ngấm vào miệng ốc. Múc ra đĩa ăn cùng rau răm và chấm bánh mì giòn tan.',
          tip: 'Không xào ốc quá lâu thịt ốc sẽ bị teo và dai.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 41. Bún Mắm Miền Tây Đậm Đà Tôm Mực Heo Quay
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_41',
      title: 'Bún Mắm Miền Tây Đậm Đà Tôm Mực Heo Quay',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
      chefName: 'Má Năm Nam Bộ',
      chefAvatar: '',
      rating: 4.92,
      reviewsCount: 390,
      cookTimeMinutes: 45,
      difficulty: 'Trung bình',
      calories: 630,
      servings: 4,
      tags: ['#BúnMắm', '#MiềnTây', '#MắmCáLinh', '#HeoQuay', '#MónNước'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 4)),
      ingredients: [
        Ingredient(
          id: 'i41_1',
          name: 'Mắm cá linh & mắm cá sặc Châu Đốc',
          amount: '200g',
        ),
        Ingredient(
          id: 'i41_2',
          name: 'Tôm sú tươi & mực ống khía hoa',
          amount: '350g',
        ),
        Ingredient(
          id: 'i41_3',
          name: 'Thịt heo quay da giòn rụm',
          amount: '300g',
        ),
        Ingredient(
          id: 'i41_4',
          name: 'Cá lóc đồng phi lê cắt khúc',
          amount: '250g',
        ),
        Ingredient(
          id: 'i41_5',
          name: 'Cà tím cắt khúc & sả băm ớt băm',
          amount: '2 quả',
        ),
        Ingredient(
          id: 'i41_6',
          name: 'Rau đắng, bông súng, kèo nèo, điên điển, giá sống',
          amount: '300g',
        ),
        Ingredient(id: 'i41_7', name: 'Bún tươi cọng to', amount: '700g'),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nấu rã mắm cá linh & Lọc nước trong',
          description:
              'Cho mắm cá linh và mắm cá sặc vào nồi cùng 500ml nước, đun sôi cho cá rã hoàn toàn. Lọc qua rây bỏ sạch xương cá lấy phần cốt mắm thơm lừng.',
          tip:
              'Nấu nước dừa xiêm cùng cốt mắm sẽ làm dịu vị mặn và tạo độ ngọt thanh tự nhiên cho nước lèo.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Phi sả ớt & Nấu nước lèo đậm đà',
          description:
              'Phi thơm sả ớt băm nhuyễn, trút vào nồi nước lèo cốt mắm cùng nước hầm xương. Thêm cà tím đun chín tới và nêm đường thốt nốt.',
          durationMinutes: 18,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trần hải sản & Bày tô bún mắm',
          description:
              'Luộc tôm sú, mực tươi và cá lóc chín tới trong nồi nước lèo. Xếp bún, hải sản, heo quay giòn rụm vào tô, chan nước lèo nóng hổi ăn cùng rổ rau đồng.',
          durationMinutes: 12,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 42. Cháo Sườn Sụn Hà Nội Quẩy Giòn Ruốc Thịt
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_42',
      title: 'Cháo Sườn Sụn Hà Nội Quẩy Giòn Ruốc Thịt',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Cụ Lý Phố Cổ',
      chefAvatar: '',
      rating: 4.89,
      reviewsCount: 310,
      cookTimeMinutes: 20,
      difficulty: 'Dễ',
      calories: 380,
      servings: 2,
      tags: ['#CháoSườnSụn', '#HàNội', '#QuẩyGiòn', '#ĂnSáng', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 8,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 11)),
      ingredients: [
        Ingredient(
          id: 'i42_1',
          name: 'Bột gạo tẻ xay nước mịn sánh như nhung',
          amount: '200g',
        ),
        Ingredient(
          id: 'i42_2',
          name: 'Sườn sụn non heo ninh mềm giòn sần sật',
          amount: '300g',
        ),
        Ingredient(
          id: 'i42_3',
          name: 'Nước hầm xương heo ngọt thanh',
          amount: '800ml',
        ),
        Ingredient(
          id: 'i42_4',
          name: 'Quẩy giòn nóng hổi cắt khoanh',
          amount: '4 cái',
        ),
        Ingredient(
          id: 'i42_5',
          name: 'Ruốc thịt heo (chà bông) thơm ngọt',
          amount: '50g',
        ),
        Ingredient(
          id: 'i42_6',
          name: 'Hạt tiêu đen xay vỡ & ớt bột cay',
          amount: '1 thìa cafe',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Hầm sườn sụn non mềm ngọt',
          description:
              'Chặt sườn sụn non miếng nhỏ, ninh trong nước xương cùng chút muối cho sụn mềm sần sật đậm đà.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Khuấy cháo bột sánh mịn không vón cục',
          description:
              'Hòa tan bột gạo nước vào nồi nước hầm sườn. Khuấy đều tay một chiều trên lửa nhỏ liu riu cho cháo chín trong suốt và sánh mịn như nhung.',
          tip:
              'Khuấy liên tục đáy nồi để cháo không bị bén cháy và đạt độ mịn dẻo chuẩn cháo phố cổ.',
          durationMinutes: 7,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Múc bát cháo nóng hổi & Rắc quẩy ruốc',
          description:
              'Múc cháo ra bát sứ, gắp sườn sụn đặt lên trên, rải quẩy giòn rụm, ruốc thịt heo và rắc nhiều tiêu đen xay thưởng thức khi còn bốc khói.',
          durationMinutes: 3,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 43. Bánh Cuốn Nóng Tráng Tay Chả Quế Nước Mắm Ấm
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_43',
      title: 'Bánh Cuốn Nóng Tráng Tay Chả Quế Nước Mắm Ấm',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=800&auto=format&fit=crop&q=80',
      chefName: 'Cô Tấm Hà Thành',
      chefAvatar: '',
      rating: 4.94,
      reviewsCount: 460,
      cookTimeMinutes: 25,
      difficulty: 'Trung bình',
      calories: 410,
      servings: 3,
      tags: ['#BánhCuốn', '#TrángTay', '#ChảQuế', '#HàNội', '#BữaSáng'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 5,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ingredients: [
        Ingredient(
          id: 'i43_1',
          name: 'Bột gạo tẻ pha bột năng tráng mỏng',
          amount: '300g',
        ),
        Ingredient(
          id: 'i43_2',
          name: 'Thịt nạc vai băm nhuyễn xào mộc nhĩ nấm hương',
          amount: '250g',
        ),
        Ingredient(
          id: 'i43_3',
          name: 'Chả quế Hà Nội thơm nức nướng vàng',
          amount: '200g',
        ),
        Ingredient(
          id: 'i43_4',
          name: 'Hành phi giòn rụm vàng ươm tự làm',
          amount: '50g',
        ),
        Ingredient(
          id: 'i43_5',
          name: 'Nước mắm chua ngọt ấm pha tinh dầu cà cuống',
          amount: '1 bát',
        ),
        Ingredient(
          id: 'i43_6',
          name: 'Rau thơm: húng quế, mùi tàu, ngò rí',
          amount: '100g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Xào nhân thịt mộc nhĩ nấm hương',
          description:
              'Phi thơm hành khô, trút thịt xay, mộc nhĩ và nấm hương băm nhỏ vào xào săn cùng tiêu xay và chút mắm nhĩ.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Tráng bánh mỏng tang & Cuộn nhân',
          description:
              'Múc muôi bột tráng mỏng trên nồi hơi nước căng vải hoặc chảo chống dính. Đậy nắp 30 giây cho bánh trong suốt, gắp ra thoa nhân thịt cuộn tròn lại.',
          tip:
              'Thoa một lớp mỏng dầu hành phi lên mặt thớt để bánh cuốn không bị dính rách.',
          durationMinutes: 12,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rắc hành phi & Chấm nước mắm ấm',
          description:
              'Xếp từng cuốn bánh mềm mướt ra đĩa, rắc ngập hành phi vàng rụm, cắt lát chả quế và chấm cùng chén nước mắm chua ngọt pha ấm dịu dàng.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 44. Bò Kho Bánh Mì Nóng Giòn Đậm Vị Sả Gừng
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_44',
      title: 'Bò Kho Bánh Mì Nóng Giòn Đậm Vị Sả Gừng',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
      chefName: 'Gordon Hải',
      chefAvatar: '',
      rating: 4.95,
      reviewsCount: 510,
      cookTimeMinutes: 45,
      difficulty: 'Trung bình',
      calories: 620,
      servings: 4,
      tags: ['#BòKho', '#BánhMì', '#ĐậmĐà', '#BữaTối', '#MónChính'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 7,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i44_1',
          name: 'Nạm bò pha gân tươi dòn sần sật',
          amount: '600g',
        ),
        Ingredient(
          id: 'i44_2',
          name: 'Gói sốt gia vị bò kho cô đặc & hoa hồi quế',
          amount: '1 gói',
        ),
        Ingredient(
          id: 'i44_3',
          name: 'Cà rốt tỉa hoa dày miếng',
          amount: '2 củ',
        ),
        Ingredient(
          id: 'i44_4',
          name: 'Sả cây đập dập & gừng nướng thơm',
          amount: '5 cây',
        ),
        Ingredient(
          id: 'i44_5',
          name: 'Nước dừa tươi ngọt thanh',
          amount: '500ml',
        ),
        Ingredient(
          id: 'i44_6',
          name: 'Bánh mì nóng giòn & rau húng quế ngò gai',
          amount: '4 ổ',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ướp nạm bò cùng gia vị bò kho',
          description:
              'Thái thịt bò khối vuông vừa ăn. Ướp gói gia vị bò kho, sả băm, tỏi, gừng, nước mắm, đường và dầu màu điều trong 30 phút.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào săn & Hầm cùng nước dừa',
          description:
              'Xào thịt bò trên lửa lớn cho thật săn thịt. Đổ nước dừa tươi và sả cây đập dập, hoa hồi vào hầm lửa nhỏ trong 30 phút cho thịt mềm ngậy.',
          tip:
              'Nước dừa xiêm tự nhiên làm thớ thịt bò mềm rục mà vẫn giữ độ ngọt đậm đà.',
          durationMinutes: 25,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Thả cà rốt & Hoàn tất sốt sánh đỏ',
          description:
              'Cho cà rốt vào nấu thêm 10 phút đến khi cà rốt mềm. Hòa chút bột năng tạo độ sánh nhẹ, múc ra tô rắc ngò gai và chấm bánh mì giòn.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 45. Lẩu Cua Đồng Bắp Bò Riêu Cua Trứng
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_45',
      title: 'Lẩu Cua Đồng Bắp Bò Riêu Cua Trứng',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Tuấn Hải',
      chefAvatar: '',
      rating: 4.96,
      reviewsCount: 540,
      cookTimeMinutes: 40,
      difficulty: 'Trung bình',
      calories: 580,
      servings: 5,
      tags: ['#LẩuCuaĐồng', '#BắpBò', '#RiêuCua', '#CuốiTuần', '#MónNước'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 4,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(
          id: 'i45_1',
          name: 'Cua đồng giã lọc lấy nước & gạch cua',
          amount: '600g',
        ),
        Ingredient(
          id: 'i45_2',
          name: 'Bắp bò hoa thái lát mỏng nhúng lẩu',
          amount: '400g',
        ),
        Ingredient(
          id: 'i45_3',
          name: 'Sườn sụn non heo chần sơ',
          amount: '350g',
        ),
        Ingredient(
          id: 'i45_4',
          name: 'Đậu phụ làng Mơ rán phồng vàng',
          amount: '4 bìa',
        ),
        Ingredient(
          id: 'i45_5',
          name: 'Giấm bỗng nếp chua thanh & cà chua',
          amount: '4 muỗng canh',
        ),
        Ingredient(
          id: 'i45_6',
          name: 'Bánh đa đỏ Hải Phòng & rau mồng tơi, hoa chuối',
          amount: '400g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nấu riêu cua đóng tảng béo ngậy',
          description:
              'Đun nước cua với chút muối trên lửa vừa đến khi riêu cua nổi dày đặc trên mặt nồi thì vớt ra tô riêng.',
          durationMinutes: 12,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nấu nước dùng lẩu giấm bỗng chua dịu',
          description:
              'Cho sườn sụn vào ninh lấy nước ngọt, thêm cà chua xào dầu điều và giấm bỗng nếp cho vị chua thanh tao dịu ngọt.',
          durationMinutes: 18,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Nhúng bắp bò hoa & Thưởng thức',
          description:
              'Bắc nồi lẩu lên bếp, thả đậu rán và gạch cua chưng. Nhúng bắp bò hoa vừa chín tái ăn cùng bánh đa đỏ và rau mồng tơi tươi non.',
          tip:
              'Nhúng bắp bò hoa trong 15 giây để thịt mềm giòn ngọt lịm không bị dai.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 46. Cá Lóc Nướng Trui Cuốn Bánh Tráng Rau Rừng
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_46',
      title: 'Cá Lóc Nướng Trui Cuốn Bánh Tráng Rau Rừng',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&auto=format&fit=crop&q=80',
      chefName: 'Út Nhỏ Miền Tây',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 290,
      cookTimeMinutes: 30,
      difficulty: 'Dễ',
      calories: 420,
      servings: 4,
      tags: ['#CáLócNướngTrui', '#MiềnTây', '#RauRừng', '#ĐặcSản', '#DânDã'],
      isFavorite: false,
      isSaved: true,
      cookedCount: 2,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 5)),
      ingredients: [
        Ingredient(
          id: 'i46_1',
          name: 'Cá lóc đồng còn tươi béo tròn',
          amount: '1kg',
        ),
        Ingredient(
          id: 'i46_2',
          name: 'Rơm nếp nướng cá thơm mùi đồng quê',
          amount: '1 bó lớn',
        ),
        Ingredient(
          id: 'i46_3',
          name: 'Mỡ hành lá tươi & đậu phộng rang giòn',
          amount: '50g',
        ),
        Ingredient(
          id: 'i46_4',
          name: 'Bánh tráng phơi sương Trảng Bàng & bún tươi',
          amount: '1 xấp',
        ),
        Ingredient(
          id: 'i46_5',
          name: 'Rau rừng: đọt cóc, lá xoài, lá cách, khế chua, chuối chát',
          amount: '300g',
        ),
        Ingredient(
          id: 'i46_6',
          name: 'Mắm nêm cá cơm pha thơm băm ớt tỏi',
          amount: '1 chén',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Xiên que tre & Nướng trui cá lóc',
          description:
              'Cá lóc để nguyên vảy rửa sạch, dùng thanh tre xiên từ miệng đến đuôi. Cắm xuống đất, phủ đầy rơm khô và châm lửa đốt cháy rực.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Cạo sạch lớp vảy cháy xém',
          description:
              'Khi tro rơm tàn, rút cá ra dùng dao cạo sạch lớp vảy ngoài bị cháy đen lộ ra thớ thịt cá trắng phau thơm lừng mùi khói rơm rạ.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Chan mỡ hành & Cuốn rau rừng chấm mắm nêm',
          description:
              'Xẻ dọc sống lưng cá, rưới mỡ hành đậu phộng thơm ngậy. Cuốn thịt cá cùng bánh tráng phơi sương, bún tươi và rau rừng chấm ngập mắm nêm.',
          tip:
              'Mắm nêm pha cùng thơm (dứa) băm nhuyễn tạo độ sánh ngọt dậy mùi đặc trưng.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 47. Cơm Chiên Dưa Bò Hà Nội Giòn Hạt Thơm Nức
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_47',
      title: 'Cơm Chiên Dưa Bò Hà Nội Giòn Hạt Thơm Nức',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Hoàng Nam',
      chefAvatar: '',
      rating: 4.9,
      reviewsCount: 380,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 520,
      servings: 2,
      tags: ['#CơmChiênDưaBò', '#HàNội', '#NhanhGọn', '#MónChính', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 9,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 14)),
      ingredients: [
        Ingredient(
          id: 'i47_1',
          name: 'Cơm nguội ráo hạt trộn lòng đỏ trứng',
          amount: '2 bát tô',
        ),
        Ingredient(
          id: 'i47_2',
          name: 'Thịt thăn bò tươi thái lát mỏng mềm',
          amount: '250g',
        ),
        Ingredient(
          id: 'i47_3',
          name: 'Dưa cải chua giòn chua dịu bóp ráo nước',
          amount: '150g',
        ),
        Ingredient(
          id: 'i47_4',
          name: 'Tỏi băm phi thơm & hành hoa thái nhỏ',
          amount: '3 muỗng',
        ),
        Ingredient(
          id: 'i47_5',
          name: 'Dầu hào, xì dầu nguyên chất, tiêu xay',
          amount: '2 muỗng',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Xào thịt bò dưa chua lửa lớn',
          description:
              'Phi thơm tỏi, cho thịt bò vào xào chín tái rồi trút dưa cải chua vào đảo nhanh tay cùng dầu hào cho ngấm đậm vị ngọt của thịt.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Rang cơm săn giòn từng hạt',
          description:
              'Cho cơm đã bóp đều lòng đỏ trứng vào chảo rang lửa lớn đảo liên tục đến khi từng hạt cơm săn lại giòn tơi óng vàng.',
          tip:
              'Trộn lòng đỏ trứng trước khi rang giúp cơm có màu vàng ruộm và hạt cơm không bị dính chùm.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trút dưa bò & Thưởng thức nóng hổi',
          description:
              'Đơm cơm chiên vàng giòn ra đĩa, múc phần dưa xào thịt bò nóng sốt đặt lên trên cùng, rắc tiêu xay và xì dầu tỏi ớt.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 48. Mực Trứng Chiên Nước Mắm Tỏi Ớt Đậm Đà
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_48',
      title: 'Mực Trứng Chiên Nước Mắm Tỏi Ớt Đậm Đà',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Nhà Út',
      chefAvatar: '',
      rating: 4.93,
      reviewsCount: 340,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 460,
      servings: 3,
      tags: ['#MựcTrứng', '#ChiênNướcMắm', '#ĐậmĐà', '#HảiSản', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 6,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 19)),
      ingredients: [
        Ingredient(
          id: 'i48_1',
          name: 'Mực trứng tươi nguyên bụng đầy trứng',
          amount: '400g',
        ),
        Ingredient(
          id: 'i48_2',
          name: 'Nước mắm ngon loại 1',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i48_3',
          name: 'Đường cát vàng & tỏi ớt băm nhuyễn',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i48_4',
          name: 'Hành tây thái múi cau & hành lá',
          amount: '1 củ',
        ),
        Ingredient(
          id: 'i48_5',
          name: 'Tương ớt cay & dưa leo ăn kèm',
          amount: 'Vừa đủ',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Chiên vàng se mặt mực trứng',
          description:
              'Rửa nhẹ mực trứng thấm thật khô. Chiên ngập dầu sôi nhanh trong 2-3 phút cho da mực săn căng phồng vàng giòn rồi vớt ra ráo dầu.',
          tip:
              'Thấm thật khô mực trước khi chiên để dầu không bắn và mực giữ nguyên bọc trứng béo bùi.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nấu sốt nước mắm tỏi ớt keo chỉ',
          description:
              'Phi thơm tỏi ớt băm, cho nước mắm, đường, chút tương ớt đun sôi lăn tăn đến khi hỗn hợp sánh kẹo lại màu cánh gián.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Đảo mực trứng bọc đều nước sốt',
          description:
              'Trút mực chiên và hành tây vào chảo sốt đảo đều tay trên lửa vừa cho sốt bám đều óng ả quanh thân từng con mực trứng bùi ngậy.',
          durationMinutes: 7,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 49. Gà Ta Ủ Muối Hoa Tiêu Da Vàng Giòn Sần Sật
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_49',
      title: 'Gà Ta Ủ Muối Hoa Tiêu Da Vàng Giòn Sần Sật',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&auto=format&fit=crop&q=80',
      chefName: 'Vua Nướng Tây Bắc',
      chefAvatar: '',
      rating: 4.95,
      reviewsCount: 480,
      cookTimeMinutes: 40,
      difficulty: 'Trung bình',
      calories: 530,
      servings: 4,
      tags: ['#GàỦMuối', '#HoaTiêu', '#DaGiòn', '#ĐặcSản', '#TiệcTùng'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 5,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(
          id: 'i49_1',
          name: 'Gà ta thả đồi da vàng ươm thịt chắc',
          amount: '1.3kg',
        ),
        Ingredient(
          id: 'i49_2',
          name: 'Muối hạt tinh khiết ủ nhiệt',
          amount: '1kg',
        ),
        Ingredient(
          id: 'i49_3',
          name: 'Hoa tiêu rừng, hạt dổi, sả cây, lá chanh',
          amount: '100g',
        ),
        Ingredient(
          id: 'i49_4',
          name: 'Nghệ tươi giã vắt nước tạo màu vàng rực',
          amount: '2 muỗng',
        ),
        Ingredient(
          id: 'i49_5',
          name: 'Muối ớt sữa đặc chấm gà chua cay mặn ngọt',
          amount: '1 chén',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Thoa nghệ tươi & Ướp gia vị hoa tiêu',
          description:
              'Thoa nước cốt nghệ đều khắp da gà cho màu vàng óng. Ướp lòng trong của gà với hoa tiêu rừng, hạt dổi rang thơm và sả đập dập.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Ủ muối hạt kín trong nồi đáy dày',
          description:
              'Rải lớp muối hạt dày 2cm dưới đáy nồi, xếp lớp sả và lá chanh rồi đặt gà lên trên. Đậy nắp kín ủ nhiệt lửa nhỏ trong 30-35 phút.',
          tip:
              'Hơi nóng muối bốc lên làm chín gà giữ trọn 100% vị ngọt đậm đà mà không cần một giọt nước nào.',
          durationMinutes: 25,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Chặt gà & Chấm sốt muối ớt sữa đặc',
          description:
              'Chặt gà thành miếng vừa ăn, lớp da vàng giòn sần sật bọc lấy thớ thịt hồng hào mọng nước chấm cùng sốt muối ớt sữa đặc chua cay.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 50. Vịt Om Sấu Nước Dừa Chua Thanh Phố Cổ
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_50',
      title: 'Vịt Om Sấu Nước Dừa Chua Thanh Phố Cổ',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800&auto=format&fit=crop&q=80',
      chefName: 'Cô Tấm Hà Thành',
      chefAvatar: '',
      rating: 4.87,
      reviewsCount: 310,
      cookTimeMinutes: 40,
      difficulty: 'Trung bình',
      calories: 550,
      servings: 4,
      tags: ['#VịtOmSấu', '#HàNội', '#QuảSấu', '#ChuaThanh', '#MónNước'],
      isFavorite: false,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 4)),
      ingredients: [
        Ingredient(
          id: 'i50_1',
          name: 'Thịt vịt cỏ làm sạch bớt mỡ chặt miếng',
          amount: '1kg',
        ),
        Ingredient(
          id: 'i50_2',
          name: 'Quả sấu tươi Hà Nội cạo sạch vỏ xanh',
          amount: '8 quả',
        ),
        Ingredient(
          id: 'i50_3',
          name: 'Khoai sọ bở dẻo mềm tơi',
          amount: '300g',
        ),
        Ingredient(
          id: 'i50_4',
          name: 'Nước dừa tươi ngọt thanh',
          amount: '400ml',
        ),
        Ingredient(
          id: 'i50_5',
          name: 'Rau ngổ, mùi tàu, hành hoa thái nhỏ',
          amount: '1 nắm',
        ),
        Ingredient(
          id: 'i50_6',
          name: 'Bún tươi sợi nhỏ ăn kèm',
          amount: '600g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Khử mùi vịt & Ướp hành tỏi gừng',
          description:
              'Xát muối gừng và rượu trắng làm sạch thịt vịt. Ướp thịt với hành tỏi băm, nước mắm, tiêu xay trong 20 phút.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào săn thịt & Om cùng sấu nước dừa',
          description:
              'Xào thịt vịt thật săn cho ra bớt mỡ. Đổ nước dừa tươi và thả quả sấu vào đun sôi rồi hạ lửa nhỏ om 20 phút cho thịt mềm.',
          durationMinutes: 20,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Dầm sấu chua & Thả khoai sọ',
          description:
              'Cho khoai sọ vào nấu chín bở, dầm quả sấu lấy vị chua thanh dịu nhẹ, rắc ngổ hương mùi tàu và ăn cùng bún tươi nóng sốt.',
          tip:
              'Dầm sấu từ từ nếm thử để vị chua thanh vừa vặn theo khẩu vị gia đình.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 51. Bắp Xào Tôm Bơ Hành Mỡ Tép Giòn Cay
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_51',
      title: 'Bắp Xào Tôm Bơ Hành Mỡ Tép Giòn Cay',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Hữu Đức',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 350,
      cookTimeMinutes: 12,
      difficulty: 'Dễ',
      calories: 310,
      servings: 2,
      tags: ['#BắpXào', '#TépKhô', '#BơHành', '#ĂnVặt', '#SàiGòn', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 11,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 7)),
      ingredients: [
        Ingredient(
          id: 'i51_1',
          name: 'Hạt bắp nếp & bắp ngọt dẻo thơm',
          amount: '300g',
        ),
        Ingredient(
          id: 'i51_2',
          name: 'Tép khô sấy đỏ ngọt cay giòn tan',
          amount: '50g',
        ),
        Ingredient(
          id: 'i51_3',
          name: 'Bơ thực vật thơm lừng Tường An',
          amount: '30g',
        ),
        Ingredient(
          id: 'i51_4',
          name: 'Hành lá tươi xắt nhỏ & ớt tươi',
          amount: '40g',
        ),
        Ingredient(
          id: 'i51_5',
          name: 'Tương ớt cay nồng xịt ăn kèm',
          amount: '2 muỗng canh',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Luộc sơ hạt bắp nếp',
          description:
              'Luộc sơ hạt bắp trong nước sôi 3 phút rồi đổ ra rổ để thật ráo nước.',
          durationMinutes: 3,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào bắp cùng bơ béo ngậy',
          description:
              'Cho bơ vào chảo đun tan chảy thơm nức mũi, trút bắp vào đảo đều trên lửa lớn cho hạt bắp căng mọng bọc bơ óng ả.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Thêm tép khô & Hành lá xắt nhỏ',
          description:
              'Cho tép khô và hành lá vào đảo đều 2 phút nêm chút đường hạt nêm, trút ra đĩa xịt tương ớt thưởng thức nóng rực.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 52. Bánh Bột Lọc Huế Tôm Thịt Trong Veo Nước Mắm Cay
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_52',
      title: 'Bánh Bột Lọc Huế Tôm Thịt Trong Veo Nước Mắm Cay',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=800&auto=format&fit=crop&q=80',
      chefName: 'Mệ Như xứ Huế',
      chefAvatar: '',
      rating: 4.93,
      reviewsCount: 420,
      cookTimeMinutes: 30,
      difficulty: 'Trung bình',
      calories: 360,
      servings: 4,
      tags: ['#BánhBộtLọc', '#XứHuế', '#TômThịt', '#ĂnVặt', '#DaiGiòn'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 4,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i52_1',
          name: 'Bột năng tinh khiết nhồi dẻo mịn',
          amount: '400g',
        ),
        Ingredient(
          id: 'i52_2',
          name: 'Tôm sông nhỏ rim mặn ngọt đậm đà',
          amount: '250g',
        ),
        Ingredient(
          id: 'i52_3',
          name: 'Thịt ba rọi thái hạt lựu rim vàng',
          amount: '200g',
        ),
        Ingredient(
          id: 'i52_4',
          name: 'Lá chuối tươi lau sạch gói bánh',
          amount: '1 xấp',
        ),
        Ingredient(
          id: 'i52_5',
          name: 'Nước mắm nhĩ cốt nguyên chất pha ớt xiêm xanh',
          amount: '1 chén',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Rim nhân tôm thịt đậm vị',
          description:
              'Phi thơm hành tỏi, trút tôm và thịt ba rọi vào rim cùng nước mắm đường tiêu cho săn keo lại màu vàng cánh gián.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nhồi bột năng & Gói bánh lá chuối',
          description:
              'Nhồi bột năng với nước sôi già đến khi dẻo mịn không dính tay. Nặn viên bột dẹt, đặt tôm thịt vào giữa gấp đôi mép bánh và gói lá chuối.',
          tip:
              'Nước nhồi bột năng bắt buộc phải sôi 100°C để bột chín tới đạt độ dẻo dai hoàn hảo.',
          durationMinutes: 12,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Hấp bánh chín trong suốt',
          description:
              'Hấp bánh cách thủy trong 15-20 phút đến khi bột trong veo nhìn rõ nhân tôm đỏ au bên trong. Thoa mỡ hành và chấm nước mắm mặn ớt cay xé lưỡi.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 53. Nem Chua Rán Hà Nội Giòn Rụm Chấm Tương Ớt
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_53',
      title: 'Nem Chua Rán Hà Nội Giòn Rụm Chấm Tương Ớt',
      category: 'Ăn vặt',
      imageUrl:
          'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Bánh Mì Phố',
      chefAvatar: '',
      rating: 4.89,
      reviewsCount: 390,
      cookTimeMinutes: 15,
      difficulty: 'Dễ',
      calories: 340,
      servings: 2,
      tags: ['#NemChuaRán', '#HàNội', '#ĂnVặt', '#GiònRụm', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 10,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ingredients: [
        Ingredient(
          id: 'i53_1',
          name: 'Nem chua sống se lạnh dẻo quánh',
          amount: '10 cây',
        ),
        Ingredient(
          id: 'i53_2',
          name: 'Bột chiên xù Panko hạt to',
          amount: '100g',
        ),
        Ingredient(
          id: 'i53_3',
          name: 'Lòng đỏ trứng gà đánh tan',
          amount: '1 quả',
        ),
        Ingredient(
          id: 'i53_4',
          name: 'Dầu ăn chiên ngập chảo',
          amount: '300ml',
        ),
        Ingredient(
          id: 'i53_5',
          name: 'Tương ớt cay nồng & dưa leo giòn mát',
          amount: 'Vừa đủ',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Lăn nem qua trứng & Bột chiên xù',
          description:
              'Nhúng từng cây nem qua lòng đỏ trứng gà rồi lăn đều qua lớp bột chiên xù hạt to bám kín thân nem.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Chiên vàng giòn rụm trong dầu sôi',
          description:
              'Đun dầu thật nóng, thả nem vào chiên lửa vừa trong 4-5 phút đến khi lớp vỏ ngoài phồng rộp giòn tan vàng ươm.',
          tip:
              'Dầu phải đủ nóng trước khi thả nem để bột xù giòn xốp và không bị ngấm dầu.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Cắt xéo & Chấm tương ớt phố cổ',
          description:
              'Cắt nem xéo miếng vừa ăn, lớp vỏ ngoài giòn rụm bên trong dẻo dai bùi béo chấm ngập tương ớt cay ăn cùng dưa leo giòn rụm.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 54. Bún Thịt Nướng Chả Giò Nam Bộ Nước Mắm Chua Ngọt
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_54',
      title: 'Bún Thịt Nướng Chả Giò Nam Bộ Nước Mắm Chua Ngọt',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Hữu Đức',
      chefAvatar: '',
      rating: 4.95,
      reviewsCount: 520,
      cookTimeMinutes: 35,
      difficulty: 'Trung bình',
      calories: 590,
      servings: 4,
      tags: ['#BúnThịtNướng', '#ChảGiò', '#NamBộ', '#MónChính'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 7,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ingredients: [
        Ingredient(
          id: 'i54_1',
          name: 'Thịt nạc dăm heo có mỡ mềm',
          amount: '500g',
        ),
        Ingredient(
          id: 'i54_2',
          name: 'Chả giò rế chiên vàng giòn rụm',
          amount: '8 cuốn',
        ),
        Ingredient(id: 'i54_3', name: 'Bún tươi sợi nhỏ', amount: '700g'),
        Ingredient(
          id: 'i54_4',
          name: 'Mỡ hành lá thơm nức & đậu phộng rang giòn',
          amount: '60g',
        ),
        Ingredient(
          id: 'i54_5',
          name: 'Đồ chua củ cải cà rốt giòn ngọt',
          amount: '1 bát',
        ),
        Ingredient(
          id: 'i54_6',
          name: 'Nước mắm tỏi ớt chanh đường pha chua ngọt',
          amount: '1 chén',
        ),
        Ingredient(
          id: 'i54_7',
          name: 'Rau sống: xà lách, giá, dưa leo, rau thơm các loại',
          amount: '250g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ướp thịt nạc dăm mật ong mè rang',
          description:
              'Thái thịt lát mỏng vừa ăn. Ướp với sả băm, tỏi, mật ong, nước mắm, xì dầu, dầu hào và mè trắng rang trong 30 phút.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nướng thịt trên than hoa đỏ rực',
          description:
              'Kẹp thịt vào vỉ nướng trên than hồng, lật đều tay đến khi thịt xém cạnh vàng nâu óng ả và tỏa mùi thơm ngây ngất.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trình bày tô bún thịt nướng hấp dẫn',
          description:
              'Xếp rau sống giá dưa dưới đáy tô, cho bún lên trên, gắp thịt nướng thơm lừng, chả giò cắt đôi, chan mỡ hành đậu phộng và rưới nước mắm chua ngọt.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 55. Nấm Bào Ngư Chiên Giòn Sốt Me Chua Ngọt Chay
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_55',
      title: 'Nấm Bào Ngư Chiên Giòn Sốt Me Chua Ngọt Chay',
      category: 'Món chay',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
      chefName: 'An Nhiên Bếp Chay',
      chefAvatar: '',
      rating: 4.87,
      reviewsCount: 210,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 270,
      servings: 3,
      tags: ['#MónChay', '#NấmBàoNgư', '#SốtMe', '#GiònRụm', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 4,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i55_1',
          name: 'Nấm bào ngư xám tươi non',
          amount: '350g',
        ),
        Ingredient(id: 'i55_2', name: 'Bột chiên giòn pha sẵn', amount: '120g'),
        Ingredient(
          id: 'i55_3',
          name: 'Nước cốt me chua thanh tự nhiên',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i55_4',
          name: 'Đường mía thốt nốt, tương ớt, xì dầu chay',
          amount: '2 muỗng',
        ),
        Ingredient(
          id: 'i55_5',
          name: 'Mè trắng rang thơm & ớt chuông thái hạt lựu',
          amount: '20g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Sơ chế & Xé nhỏ nấm bào ngư',
          description:
              'Ngâm rửa sạch nấm bào ngư trong nước muối loãng, vắt thật ráo nước và xé thành từng dải nhỏ vừa ăn.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Áo bột & Chiên vàng giòn rụm',
          description:
              'Lăn nấm qua lớp bột chiên giòn mỏng. Thả vào chảo dầu sôi chiên vàng rụm trong 4 phút rồi vớt ra giấy thấm dầu.',
          durationMinutes: 7,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Đảo nhanh cùng sốt me chua ngọt',
          description:
              'Nấu nước cốt me, đường thốt nốt và xì dầu chay sánh sệt. Trút nấm chiên vào đảo nhanh tay 1 phút cho sốt áo đều rồi rắc mè rang thơm phức.',
          tip:
              'Đảo trên lửa lớn thật nhanh để nấm giữ trọn độ giòn tan không bị ỉu.',
          durationMinutes: 6,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 56. Hủ Tiếu Chay Thanh Ngọt Nước Hầm Lê Táo Củ Quả
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_56',
      title: 'Hủ Tiếu Chay Thanh Ngọt Nước Hầm Lê Táo Củ Quả',
      category: 'Món chay',
      imageUrl:
          'https://images.unsplash.com/photo-1594998893017-36147cbcae05?w=800&auto=format&fit=crop&q=80',
      chefName: 'An Nhiên Bếp Chay',
      chefAvatar: '',
      rating: 4.91,
      reviewsCount: 310,
      cookTimeMinutes: 35,
      difficulty: 'Dễ',
      calories: 390,
      servings: 4,
      tags: ['#HủTiếuChay', '#MónChay', '#ThanhNgọt', '#RauCủ', '#MónNước'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(id: 'i56_1', name: 'Sợi hủ tiếu dai Sa Đéc', amount: '500g'),
        Ingredient(
          id: 'i56_2',
          name: 'Lê ngọt, táo đỏ, bắp ngọt, củ cải trắng hầm nước',
          amount: '600g',
        ),
        Ingredient(
          id: 'i56_3',
          name: 'Đậu hũ chiên vàng & chả lụa chay thái lát',
          amount: '200g',
        ),
        Ingredient(
          id: 'i56_4',
          name: 'Nấm đùi gà & nấm rơm búp tươi',
          amount: '150g',
        ),
        Ingredient(
          id: 'i56_5',
          name: 'Hành bo-rô (tỏi tây) phi thơm vàng ươm',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i56_6',
          name: 'Hẹ lá, cần tây, giá đỗ, ngò rí',
          amount: '150g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Hầm nước củ quả thanh khiết ngọt lịm',
          description:
              'Hầm lê tươi, táo đỏ, bắp ngọt, củ cải trắng lửa riu riu trong 25 phút. Nước dùng thu được trong veo và có vị ngọt sâu thanh khiết.',
          durationMinutes: 15,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào nấm đùi gà cùng hành bo-rô',
          description:
              'Phi thơm hành bo-rô, cho nấm đùi gà và nấm rơm xào thơm cùng chút hạt nêm nấm rồi trút vào nồi nước lèo.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trần hủ tiếu & Thưởng thức tô chay ấm áp',
          description:
              'Trần hủ tiếu vào tô, xếp đậu hũ chiên, chả lụa chay, nấm ngọt, cần tây, chan nước lèo nóng hổi và rắc thật nhiều bo-rô phi thơm.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 57. Cơm Chiên Ngũ Sắc Hạt Sen Đậu Hà Lan Chay
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_57',
      title: 'Cơm Chiên Ngũ Sắc Hạt Sen Đậu Hà Lan Chay',
      category: 'Món chay',
      imageUrl:
          'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=800&auto=format&fit=crop&q=80',
      chefName: 'An Nhiên Bếp Chay',
      chefAvatar: '',
      rating: 4.85,
      reviewsCount: 190,
      cookTimeMinutes: 16,
      difficulty: 'Dễ',
      calories: 330,
      servings: 2,
      tags: ['#CơmChiênChay', '#NgũSắc', '#HạtSen', '#ThanhĐạm', '< 20 phút'],
      isFavorite: false,
      isSaved: true,
      cookedCount: 5,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 4)),
      ingredients: [
        Ingredient(
          id: 'i57_1',
          name: 'Cơm nguội ráo hạt dẻo thơm',
          amount: '2 bát',
        ),
        Ingredient(
          id: 'i57_2',
          name: 'Hạt sen tươi luộc chín bùi bở',
          amount: '80g',
        ),
        Ingredient(
          id: 'i57_3',
          name: 'Đậu Hà Lan xanh mướt & ngô ngọt',
          amount: '80g',
        ),
        Ingredient(
          id: 'i57_4',
          name: 'Cà rốt & nấm đông cô thái hạt lựu nhỏ',
          amount: '60g',
        ),
        Ingredient(
          id: 'i57_5',
          name: 'Dầu màu điều & xì dầu nấm hương chay',
          amount: '2 muỗng canh',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Sơ chế rau củ hạt sen',
          description:
              'Luộc sơ hạt sen, đậu Hà Lan, bắp ngọt và cà rốt hạt lựu cho chín tới giữ màu sắc rực rỡ.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Rang cơm săn giòn cùng dầu điều',
          description:
              'Trộn cơm nguội với 1 thìa dầu màu điều cho màu cam óng ả. Rang cơm trên chảo chống dính lửa lớn cho hạt săn tơi.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Trộn rau củ ngũ sắc & Nêm xì dầu',
          description:
              'Trút toàn bộ hạt sen và rau củ vào đảo chung cùng cơm trong 3 phút, nêm xì dầu nấm hương vừa miệng rắc tiêu thơm.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 58. Bò Lát Chay Xào Sả Ớt Lá Lốt Đậm Đà
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_58',
      title: 'Bò Lát Chay Xào Sả Ớt Lá Lốt Đậm Đà',
      category: 'Món chay',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
      chefName: 'An Nhiên Bếp Chay',
      chefAvatar: '',
      rating: 4.89,
      reviewsCount: 220,
      cookTimeMinutes: 15,
      difficulty: 'Dễ',
      calories: 280,
      servings: 3,
      tags: [
        '#BòLátChay',
        '#SảỚt',
        '#LáLốt',
        '#MónChay',
        '#ĐậmĐà',
        '< 20 phút',
      ],
      isFavorite: true,
      isSaved: true,
      cookedCount: 6,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 17)),
      ingredients: [
        Ingredient(
          id: 'i58_1',
          name: 'Bò lát chay từ đậu nành ngâm nở xé sợi',
          amount: '150g',
        ),
        Ingredient(
          id: 'i58_2',
          name: 'Lá lốt tươi rửa sạch thái sợi',
          amount: '1 nắm lớn',
        ),
        Ingredient(
          id: 'i58_3',
          name: 'Sả băm nhuyễn & ớt hiểm đỏ băm cay',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i58_4',
          name: 'Dầu hào chay từ nấm & nước tương hảo vị',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i58_5',
          name: 'Đậu phộng rang vàng giã nhỏ',
          amount: '2 muỗng',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ướp bò lát chay cùng sả ớt',
          description:
              'Vắt ráo nước bò lát chay, ướp cùng dầu hào chay, xì dầu, một nửa phần sả ớt băm trong 10 phút.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào săn bò lát thơm nồng',
          description:
              'Phi thơm phần sả ớt còn lại, trút bò lát chay vào xào săn trên lửa lớn cho ngấm đẫm vị sả cay cay mặn mặn.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Thả lá lốt & Rắc đậu phộng',
          description:
              'Cho lá lốt thái sợi vào đảo nhanh trong 30 giây cho vừa chín tới tỏa mùi thơm đặc trưng, trút ra đĩa rắc đậu phộng rang giòn.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 59. Chả Giò Chay Nấm Khoai Môn Rế Giòn Rụm
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_59',
      title: 'Chả Giò Chay Nấm Khoai Môn Rế Giòn Rụm',
      category: 'Món chay',
      imageUrl:
          'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=800&auto=format&fit=crop&q=80',
      chefName: 'An Nhiên Bếp Chay',
      chefAvatar: '',
      rating: 4.92,
      reviewsCount: 380,
      cookTimeMinutes: 25,
      difficulty: 'Trung bình',
      calories: 350,
      servings: 4,
      tags: ['#ChảGiòChay', '#KhoaiMôn', '#Nấm', '#GiònTan', '#MónChay'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 7,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i59_1',
          name: 'Bánh tráng rế cuốn chả giò giòn xốp',
          amount: '1 xấp',
        ),
        Ingredient(id: 'i59_2', name: 'Khoai môn bào sợi nhỏ', amount: '200g'),
        Ingredient(
          id: 'i59_3',
          name: 'Đậu xanh hấp chín giã bùi',
          amount: '100g',
        ),
        Ingredient(
          id: 'i59_4',
          name: 'Nấm mèo & nấm hương băm nhỏ',
          amount: '80g',
        ),
        Ingredient(
          id: 'i59_5',
          name: 'Cà rốt bào sợi & miến dong cắt khúc',
          amount: '80g',
        ),
        Ingredient(
          id: 'i59_6',
          name: 'Sốt xí muội ngọt thanh chấm kèm',
          amount: '1 chén',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Trộn đều nhân khoai môn nấm',
          description:
              'Trộn đều khoai môn, đậu xanh, nấm mèo, cà rốt và miến cùng chút hạt nêm chay và tiêu đen xay.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Cuốn chả giò bằng bánh tráng rế',
          description:
              'Đặt nhân vào bánh tráng rế cuộn chặt hai đầu thành từng cuốn tròn đều tay xinh xắn.',
          durationMinutes: 9,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Chiên vàng giòn rụm & Thưởng thức',
          description:
              'Chiên ngập dầu trên lửa vừa đến khi lớp vỏ rế vàng óng giòn rụm. Vớt ra để ráo dầu và chấm sốt xí muội chua ngọt.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 60. Sushi Cá Hồi & Trứng Cuộn Tamagoyaki Nhật Bản
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_60',
      title: 'Sushi Cá Hồi & Trứng Cuộn Tamagoyaki Nhật Bản',
      category: 'Eat Clean',
      imageUrl:
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Kenji Sato',
      chefAvatar: '',
      rating: 4.96,
      reviewsCount: 450,
      cookTimeMinutes: 20,
      difficulty: 'Trung bình',
      calories: 360,
      servings: 2,
      tags: [
        '#Sushi',
        '#CáHồi',
        '#NhậtBản',
        '#EatClean',
        '#Tamagoyaki',
        '< 20 phút',
      ],
      isFavorite: true,
      isSaved: true,
      cookedCount: 8,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ingredients: [
        Ingredient(
          id: 'i60_1',
          name: 'Cơm gạo Nhật trộn giấm sushi dẻo ngọt',
          amount: '2 bát',
        ),
        Ingredient(
          id: 'i60_2',
          name: 'Phi lê cá hồi Na Uy tươi sống Sashimi grade',
          amount: '200g',
        ),
        Ingredient(
          id: 'i60_3',
          name: 'Trứng cuộn Tamagoyaki ngọt dịu',
          amount: '2 quả',
        ),
        Ingredient(
          id: 'i60_4',
          name: 'Lá rong biển Nori nướng giòn',
          amount: '4 lá',
        ),
        Ingredient(
          id: 'i60_5',
          name: 'Quả bơ sáp cắt que & dưa chuột Nhật',
          amount: '1 trái',
        ),
        Ingredient(
          id: 'i60_6',
          name: 'Nước tương Nhật Kikkoman & Wasabi tươi',
          amount: 'Vừa đủ',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Trộn cơm giấm sushi chuẩn Nhật',
          description:
              'Cơm gạo Nhật chín nóng xới tơi, rưới hỗn hợp giấm gạo, đường và muối khuấy nhẹ tay quạt nguội.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Cuộn sushi trên mành tre Makisu',
          description:
              'Trải lá rong biển lên mành tre, dàn đều lớp cơm mỏng, xếp cá hồi thái que, bơ sáp và trứng Tamagoyaki rồi cuộn chặt tay.',
          tip:
              'Dùng dao thật sắc nhúng qua nước ấm để cắt sushi từng khoanh gọn gàng không bị nát mép.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Cắt khoanh tròn & Chấm nước tương Wasabi',
          description:
              'Cắt cuộn sushi thành từng khoanh đều nhau, xếp ra đĩa sứ đen ăn kèm gừng ngâm chua ngọt Gari và chấm mù tạt tươi cay nồng.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 61. Mì Udon Xào Bò Rau Củ Sốt Dầu Hào Nhật Bản
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_61',
      title: 'Mì Udon Xào Bò Rau Củ Sốt Dầu Hào Nhật Bản',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Kenji Sato',
      chefAvatar: '',
      rating: 4.89,
      reviewsCount: 330,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 490,
      servings: 2,
      tags: ['#MìUdon', '#XàoBò', '#NhậtBản', '#NhanhGọn', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 7,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 10)),
      ingredients: [
        Ingredient(
          id: 'i61_1',
          name: 'Sợi mì Udon tươi Nhật Bản dẻo dai',
          amount: '2 gói',
        ),
        Ingredient(
          id: 'i61_2',
          name: 'Thịt ba chỉ bò Mỹ cuộn thái lát mỏng',
          amount: '250g',
        ),
        Ingredient(
          id: 'i61_3',
          name: 'Bắp cải, cà rốt, nấm đông cô tươi thái sợi',
          amount: '150g',
        ),
        Ingredient(
          id: 'i61_4',
          name: 'Nước sốt xào Udon: xì dầu, dầu hào, rượu Mirin',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i61_5',
          name: 'Cá ngừ bào Katsuobushi & mè rang',
          amount: '20g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Chần sợi mì Udon dẻo dai',
          description:
              'Chần mì Udon trong nước sôi 1 phút cho sợi mì tơi mềm, vớt ra xả nước lạnh để giữ độ dai giòn sần sật.',
          durationMinutes: 4,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào thịt bò & Rau củ quả',
          description:
              'Xào thịt ba chỉ bò chín tới, cho bắp cải, cà rốt và nấm vào đảo nhanh tay trên lửa lớn.',
          durationMinutes: 7,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Đảo mì Udon cùng sốt sánh nâu',
          description:
              'Trút mì Udon và hỗn hợp sốt xào vào chảo đảo đều trong 3 phút cho sốt ngấm vào sợi mì, rắc cá ngừ bào nhảy múa trên đĩa nóng.',
          durationMinutes: 7,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 62. Cơm Chiên Kimchi Trứng Lòng Đào Rong Biển Hàn Quốc
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_62',
      title: 'Cơm Chiên Kimchi Trứng Lòng Đào Rong Biển Hàn Quốc',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1541544741938-0af808871cc0?w=800&auto=format&fit=crop&q=80',
      chefName: 'Oppa Kim Kitchen',
      chefAvatar: '',
      rating: 4.88,
      reviewsCount: 370,
      cookTimeMinutes: 15,
      difficulty: 'Dễ',
      calories: 450,
      servings: 2,
      tags: [
        '#CơmChiênKimchi',
        '#HànQuốc',
        '#TrứngLòngĐào',
        '#NhanhGọn',
        '< 20 phút',
      ],
      isFavorite: true,
      isSaved: true,
      cookedCount: 12,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ingredients: [
        Ingredient(
          id: 'i62_1',
          name: 'Kimchi cải thảo lên men chua cay băm nhỏ',
          amount: '150g',
        ),
        Ingredient(id: 'i62_2', name: 'Cơm nguội khô ráo hạt', amount: '2 bát'),
        Ingredient(
          id: 'i62_3',
          name: 'Thịt ba chỉ heo hoặc xúc xích lát',
          amount: '150g',
        ),
        Ingredient(
          id: 'i62_4',
          name: 'Tương ớt Gochujang & dầu mè nguyên chất',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i62_5',
          name: 'Trứng gà ốp la lòng đào & rong biển vụn',
          amount: '2 quả',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Xào thịt heo cùng kimchi dậy mùi thơm',
          description:
              'Cho thịt vào chảo xào cháy cạnh, trút kimchi băm nhỏ cùng nước sốt kimchi và tương ớt Gochujang vào xào sôi lăn tăn.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Rang cơm bọc sốt đỏ óng ả',
          description:
              'Cho cơm vào chảo dằm tơi hạt, đảo đều tay cho cơm ngấm trọn màu đỏ cam và vị cay chua đậm đà của kimchi, rưới 1 thìa dầu mè thơm.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Đặt trứng lòng đào & Rắc rong biển',
          description:
              'Xới cơm ra đĩa, đặt quả trứng ốp la lòng đào lên trên, rắc thật nhiều rong biển sấy vụn giòn tan và mè rang.',
          tip:
              'Dằm lòng đỏ trứng lòng đào béo ngậy trộn cùng cơm cay nồng tạo nên vị ngon tuyệt hảo.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 63. Canh Sườn Bò Galbitang Hầm Củ Cải Thanh Ngọt
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_63',
      title: 'Canh Sườn Bò Galbitang Hầm Củ Cải Thanh Ngọt',
      category: 'Món nước',
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&auto=format&fit=crop&q=80',
      chefName: 'Oppa Kim Kitchen',
      chefAvatar: '',
      rating: 4.94,
      reviewsCount: 360,
      cookTimeMinutes: 50,
      difficulty: 'Trung bình',
      calories: 520,
      servings: 4,
      tags: ['#Galbitang', '#CanhSườnBò', '#HànQuốc', '#BổDưỡng', '#MónNước'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 3,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ingredients: [
        Ingredient(
          id: 'i63_1',
          name: 'Dẻ sườn bò tươi cắt khúc hầm',
          amount: '800g',
        ),
        Ingredient(
          id: 'i63_2',
          name: 'Củ cải trắng Hàn Quốc cắt khối lớn',
          amount: '400g',
        ),
        Ingredient(
          id: 'i63_3',
          name: 'Miến dong Hàn Quốc ngâm mềm',
          amount: '100g',
        ),
        Ingredient(
          id: 'i63_4',
          name: 'Táo đỏ, tỏi tép, hành baro, hạt tiêu đen',
          amount: '50g',
        ),
        Ingredient(
          id: 'i63_5',
          name: 'Nước tương ganjang & muối biển',
          amount: '2 muỗng canh',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ngâm xả tiết sườn & Chần sơ',
          description:
              'Ngâm sườn bò trong nước lạnh 1 giờ để nhả hết máu đọng. Chần sườn qua nước sôi 5 phút rửa sạch bọt cặn.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Hầm sườn bò cùng củ cải trắng',
          description:
              'Hầm sườn bò cùng củ cải, hành baro, tỏi tép và táo đỏ trong 40 phút lửa nhỏ cho thịt mềm rục róc xương nước trong ngọt lịm.',
          tip:
              'Hớt sạch bọt và mỡ thừa trong lúc hầm để nước canh thanh trong không ngấy.',
          durationMinutes: 30,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Thả miến dong & Thưởng thức thố đá nóng',
          description:
              'Múc sườn bò và củ cải vào thố đá đun sôi, thả miến dong ngâm mềm, rắc hành hoa thái nhỏ tiêu đen và ăn cùng cơm nóng kimchi.',
          durationMinutes: 10,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 64. Pad Thai Tôm Tươi Hủ Tiếu Xào Me Đậu Phộng
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_64',
      title: 'Pad Thai Tôm Tươi Hủ Tiếu Xào Me Đậu Phộng',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Somchai',
      chefAvatar: '',
      rating: 4.93,
      reviewsCount: 460,
      cookTimeMinutes: 18,
      difficulty: 'Dễ',
      calories: 510,
      servings: 2,
      tags: ['#PadThai', '#TômTươi', '#TháiLan', '#SốtMe', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 9,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 16)),
      ingredients: [
        Ingredient(
          id: 'i64_1',
          name: 'Sợi hủ tiếu bánh phở Pad Thai dai mềm',
          amount: '250g',
        ),
        Ingredient(
          id: 'i64_2',
          name: 'Tôm sú tươi lột vỏ chừa đuôi',
          amount: '200g',
        ),
        Ingredient(
          id: 'i64_3',
          name: 'Đậu hũ vàng cắt hạt lựu & trứng gà',
          amount: '2 quả',
        ),
        Ingredient(
          id: 'i64_4',
          name: 'Nước cốt me, đường thốt nốt, nước mắm Thái',
          amount: '3 muỗng canh',
        ),
        Ingredient(
          id: 'i64_5',
          name: 'Giá đỗ sống, hẹ lá, đậu phộng rang giã nhỏ, ớt bột',
          amount: '100g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Pha sốt Pad Thai chua ngọt cân bằng',
          description:
              'Đun tan chảy đường thốt nốt cùng nước cốt me và nước mắm ngon tạo thành hỗn hợp sốt đậm đà chua ngọt hài hòa.',
          durationMinutes: 4,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào tôm & Tráng trứng tơi',
          description:
              'Áp chảo tôm sú cho chín đỏ se mặt, gạt sang góc chảo rồi đập trứng vào đảo tơi cùng đậu hũ vàng.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Xào hủ tiếu cùng sốt & Đậu phộng',
          description:
              'Cho bánh hủ tiếu và sốt me vào đảo lửa lớn trong 3 phút, thêm giá hẹ đảo nhanh rồi trút ra đĩa rắc đậu phộng rang và vắt chanh tươi.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 65. Cà Ri Gà Nước Cốt Dừa Kiểu Thái Bánh Mì Giòn
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_65',
      title: 'Cà Ri Gà Nước Cốt Dừa Kiểu Thái Bánh Mì Giòn',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Somchai',
      chefAvatar: '',
      rating: 4.9,
      reviewsCount: 340,
      cookTimeMinutes: 35,
      difficulty: 'Trung bình',
      calories: 610,
      servings: 4,
      tags: ['#CàRiGà', '#NướcCốtDừa', '#TháiLan', '#BéoNgậy', '#BánhMì'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 4,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ingredients: [
        Ingredient(
          id: 'i65_1',
          name: 'Thịt gà ta chặt miếng vừa ăn',
          amount: '700g',
        ),
        Ingredient(
          id: 'i65_2',
          name: 'Bột cà ri vàng & sốt cà ri đỏ Thái Lan',
          amount: '2 muỗng canh',
        ),
        Ingredient(
          id: 'i65_3',
          name: 'Nước cốt dừa nguyên chất béo ngậy',
          amount: '350ml',
        ),
        Ingredient(
          id: 'i65_4',
          name: 'Khoai lang mật & khoai tây chiên vàng mặt',
          amount: '300g',
        ),
        Ingredient(
          id: 'i65_5',
          name: 'Sả cây đập dập & lá chanh Thái thơm lừng',
          amount: '4 cây',
        ),
        Ingredient(
          id: 'i65_6',
          name: 'Bánh mì baguette giòn rụm hoặc cơm trắng',
          amount: '4 ổ',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Xào sốt cà ri dậy dầu màu béo',
          description:
              'Đun sôi 1 nửa phần nước cốt dừa cho tách béo, cho bột cà ri và sốt cà ri đỏ vào xào thơm nức mũi.',
          durationMinutes: 6,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Xào gà săn & Hầm cùng khoai',
          description:
              'Trút thịt gà vào xào ngấm sốt, cho sả cây và nước cốt dừa còn lại vào hầm lửa vừa 15 phút. Thêm khoai lang đã chiên vào hầm mềm.',
          tip:
              'Chiên sơ khoai trước khi nấu giúp khoai không bị nát nhừ trong nồi cà ri.',
          durationMinutes: 20,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Nêm lá chanh Thái & Chấm bánh mì',
          description:
              'Vò nhẹ lá chanh Thái thả vào nồi cà ri tắt bếp. Múc ra tô sánh vàng béo ngậy chấm bánh mì giòn tan tuyệt đỉnh.',
          durationMinutes: 9,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 66. Mì Ý Spaghetti Sốt Bò Bằm Bolognese Phô Mai
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_66',
      title: 'Mì Ý Spaghetti Sốt Bò Bằm Bolognese Phô Mai',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Giovanni Hải',
      chefAvatar: '',
      rating: 4.94,
      reviewsCount: 570,
      cookTimeMinutes: 20,
      difficulty: 'Dễ',
      calories: 540,
      servings: 3,
      tags: ['#Spaghetti', '#Bolognese', '#MìÝ', '#PhôMai', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 11,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ingredients: [
        Ingredient(
          id: 'i66_1',
          name: 'Mì Spaghetti Barilla số 5 Al Dente',
          amount: '300g',
        ),
        Ingredient(
          id: 'i66_2',
          name: 'Thịt bò Úc tươi xay ngọt mềm',
          amount: '350g',
        ),
        Ingredient(
          id: 'i66_3',
          name: 'Sốt cà chua nguyên trái nghiền Pelati Ý',
          amount: '1 hộp',
        ),
        Ingredient(
          id: 'i66_4',
          name: 'Cần tây, cà rốt, hành tây băm nhuyễn',
          amount: '100g',
        ),
        Ingredient(
          id: 'i66_5',
          name: 'Lá thơm Oregano, húng tây Basil, bơ tỏi',
          amount: '1 muỗng',
        ),
        Ingredient(
          id: 'i66_6',
          name: 'Phô mai bột Parmesan bào phủ tuyết',
          amount: '30g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Luộc sợi mì Spaghetti Al Dente chuẩn Ý',
          description:
              'Đun sôi 2 lít nước cùng 1 thìa muối tinh. Thả mì vào luộc đúng 8 phút cho sợi mì chín tới dai mềm dẻo sần sật.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nấu sốt bò bằm Bolognese thơm lừng',
          description:
              'Xào thơm hành tây cần tây bơ tỏi, trút thịt bò xay vào xào săn tơi. Đổ sốt cà chua Pelati và lá thơm vào đun liu riu sánh mịn.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Cuộn mì ra đĩa & Phủ phô mai tuyết',
          description:
              'Cuộn mì Spaghetti ra đĩa tròn, múc ngập sốt bò bằm nóng hổi lên giữa đĩa, rắc phô mai Parmesan bào mịn phủ kín mặt mì thơm ngát.',
          durationMinutes: 4,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 67. Beefsteak Thăn Bò Mỹ Sốt Rượu Vang Đỏ Khoai Nghiền
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_67',
      title: 'Beefsteak Thăn Bò Mỹ Sốt Rượu Vang Đỏ Khoai Nghiền',
      category: 'Món chính',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&auto=format&fit=crop&q=80',
      chefName: 'Chef Daniel Phạm',
      chefAvatar: '',
      rating: 4.98,
      reviewsCount: 620,
      cookTimeMinutes: 20,
      difficulty: 'Trung bình',
      calories: 630,
      servings: 2,
      tags: [
        '#Beefsteak',
        '#BòMỹ',
        '#SốtRượuVang',
        '#KhoaiNghiền',
        '< 20 phút',
      ],
      isFavorite: true,
      isSaved: true,
      cookedCount: 5,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ingredients: [
        Ingredient(
          id: 'i67_1',
          name: 'Thăn bò Mỹ Black Angus Ribeye dày 2.5cm',
          amount: '400g',
        ),
        Ingredient(id: 'i67_2', name: 'Bơ lạt hảo hạng Anchor', amount: '40g'),
        Ingredient(
          id: 'i67_3',
          name: 'Nhánh hương thảo tươi (Rosemary) & tỏi nguyên tép',
          amount: '2 nhánh',
        ),
        Ingredient(
          id: 'i67_4',
          name: 'Rượu vang đỏ Cabernet Sauvignon làm sốt',
          amount: '80ml',
        ),
        Ingredient(
          id: 'i67_5',
          name: 'Khoai tây nghiền kem tươi bơ sữa béo mịn',
          amount: '200g',
        ),
        Ingredient(
          id: 'i67_6',
          name: 'Muối hạt hồng Himalaya & tiêu đen đập dập',
          amount: '1 thìa cafe',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Thấm khô miếng thăn & Ướp muối tiêu',
          description:
              'Thấm thật khô hai mặt miếng thịt bò. Rắc muối hồng và tiêu đen giã vỡ xoa đều khắp bề mặt thịt.',
          durationMinutes: 4,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Áp chảo lửa lớn tưới bơ lá thơm',
          description:
              'Đun chảo gang thật nóng, áp chảo mỗi mặt 2 phút cho cháy xém nâu vàng. Thả bơ lạt, tỏi đập dập và hương thảo, dùng thìa rưới liên tục bơ nóng lên mặt thịt đạt chuẩn Medium Rare.',
          tip:
              'Để thịt nghỉ (Resting) đúng 5 phút trên thớt trước khi cắt để nước thịt ngọt giữ trọn bên trong.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Nấu sốt vang đỏ & Trình bày đĩa Âu',
          description:
              'Cho rượu vang đỏ vào chảo vừa áp chảo đun cô đặc sánh mịn. Cắt thịt bò lát dày mọng nước đặt cạnh khoai tây nghiền mượt mà rưới sốt vang.',
          durationMinutes: 8,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 68. Trà Sen Vàng Macchiato Hạt Sen Bùi Béo
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_68',
      title: 'Trà Sen Vàng Macchiato Hạt Sen Bùi Béo',
      category: 'Đồ uống',
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=800&auto=format&fit=crop&q=80',
      chefName: 'Barista Vy Vy',
      chefAvatar: '',
      rating: 4.92,
      reviewsCount: 470,
      cookTimeMinutes: 12,
      difficulty: 'Dễ',
      calories: 190,
      servings: 2,
      tags: ['#TràSenVàng', '#Macchiato', '#HạtSen', '#Highlands', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 15,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ingredients: [
        Ingredient(
          id: 'i68_1',
          name: 'Trà Ô long hương sen thượng hạng',
          amount: '15g',
        ),
        Ingredient(
          id: 'i68_2',
          name: 'Hạt sen tươi hầm đường phèn bùi ngậy',
          amount: '80g',
        ),
        Ingredient(
          id: 'i68_3',
          name: 'Củ năng tươi thái hạt lựu áo bột năng giòn',
          amount: '60g',
        ),
        Ingredient(
          id: 'i68_4',
          name: 'Whipping cream & sữa tươi đánh bông Macchiato',
          amount: '80ml',
        ),
        Ingredient(
          id: 'i68_5',
          name: 'Muối biển & đường phèn nước',
          amount: '20ml',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Ủ cốt trà Ô long sen thanh ngát',
          description:
              'Ủ trà Ô long sen với 300ml nước nóng 90°C trong 10 phút, lọc bỏ xác trà lấy nước cốt thơm dịu.',
          durationMinutes: 5,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Đánh bông lớp kem Macchiato sánh mịn',
          description:
              'Đánh kem tươi, sữa tươi và chút muối biển trong 40 giây tạo lớp kem cheese mặn mặn béo ngậy mềm như mây.',
          durationMinutes: 4,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rót ly & Thêm hạt sen củ năng giòn sần sật',
          description:
              'Cho đá viên và nước trà vào ly, múc hạt sen bở bùi và củ năng giòn vào đáy ly, nhẹ nhàng phủ lớp Macchiato trắng muốt lên trên cùng.',
          durationMinutes: 3,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 69. Chè Dừa Dầm Hải Phòng Thạch Dừa Non Cốt Dừa
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_69',
      title: 'Chè Dừa Dầm Hải Phòng Thạch Dừa Non Cốt Dừa',
      category: 'Bánh ngọt',
      imageUrl:
          'https://images.unsplash.com/photo-1528975604071-b4dc52a2d18c?w=800&auto=format&fit=crop&q=80',
      chefName: 'Cô Bảy Miền Trung',
      chefAvatar: '',
      rating: 4.95,
      reviewsCount: 510,
      cookTimeMinutes: 20,
      difficulty: 'Dễ',
      calories: 280,
      servings: 4,
      tags: ['#ChèDừaDầm', '#HảiPhòng', '#ThạchDừa', '#CốtDừa', '< 20 phút'],
      isFavorite: true,
      isSaved: true,
      cookedCount: 13,
      lastViewedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ingredients: [
        Ingredient(
          id: 'i69_1',
          name: 'Cùi dừa non bào sợi dài mỏng giòn sần sật',
          amount: '200g',
        ),
        Ingredient(
          id: 'i69_2',
          name: 'Thạch rau câu dừa tươi trong veo',
          amount: '150g',
        ),
        Ingredient(
          id: 'i69_3',
          name: 'Trân châu nhân dừa luộc dai dẻo',
          amount: '120g',
        ),
        Ingredient(
          id: 'i69_4',
          name: 'Nước cốt dừa tươi béo ngậy nấu sữa đặc',
          amount: '300ml',
        ),
        Ingredient(
          id: 'i69_5',
          name: 'Đá bào nhuyễn mát lạnh tê răng',
          amount: '1 bát lớn',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nấu nước cốt dừa béo ngọt thơm vani',
          description:
              'Đun nước cốt dừa cùng sữa đặc và chút xíu muối trên lửa nhỏ cho ấm mịn, để thật nguội.',
          durationMinutes: 8,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Luộc trân châu nhân dừa giòn dai',
          description:
              'Luộc hạt trân châu trong nước sôi đến khi nổi lên dẻo trong, vớt ngâm nước đường cho hạt bóng bẩy không dính.',
          durationMinutes: 7,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Múc ly chè dừa dầm đá bào mát lạnh',
          description:
              'Cho cùi dừa non sợi, thạch dừa giòn và trân châu vào ly, chan ngập nước cốt dừa béo ngậy thêm đá bào thưởng thức cực đã.',
          durationMinutes: 5,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // 70. Bánh Bông Lan Trứng Muối Sốt Phô Mai Hoàng Kim
    // -------------------------------------------------------------------------
    Recipe(
      id: 'rec_70',
      title: 'Bánh Bông Lan Trứng Muối Sốt Phô Mai Hoàng Kim',
      category: 'Bánh ngọt',
      imageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop&q=80',
      chefName: 'Bếp Bánh TiTi',
      chefAvatar: '',
      rating: 4.97,
      reviewsCount: 680,
      cookTimeMinutes: 40,
      difficulty: 'Trung bình',
      calories: 420,
      servings: 6,
      tags: [
        '#BánhBôngLan',
        '#TrứngMuối',
        '#PhôMaiHoàngKim',
        '#ChàBông',
        '#BánhNgọt',
      ],
      isFavorite: true,
      isSaved: true,
      cookedCount: 8,
      lastViewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ingredients: [
        Ingredient(
          id: 'i70_1',
          name: 'Cốt bánh bông lan bơ sữa mềm xốp như mây',
          amount: '1 ổ tròn 18cm',
        ),
        Ingredient(
          id: 'i70_2',
          name: 'Lòng đỏ trứng muối nướng rượu thơm phức',
          amount: '6 quả',
        ),
        Ingredient(
          id: 'i70_3',
          name: 'Sốt phô mai kem béo ngậy sóng sánh hoàng kim',
          amount: '120g',
        ),
        Ingredient(
          id: 'i70_4',
          name: 'Sốt dầu trứng bóng bẩy dẻo ngọt',
          amount: '60g',
        ),
        Ingredient(
          id: 'i70_5',
          name: 'Chà bông heo (ruốc) tơi xốp cay ngọt',
          amount: '80g',
        ),
      ],
      steps: [
        const CookingStep(
          stepNumber: 1,
          title: 'Nướng trứng muối cùng rượu thơm',
          description:
              'Rửa sạch lòng đỏ trứng muối với rượu mai quế lộ, quét dầu mè nướng ở 160°C trong 7 phút cho chín bở thơm phức.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 2,
          title: 'Nấu sốt phô mai hoàng kim béo ngậy',
          description:
              'Đun tan chảy phô mai cùng sữa tươi, bơ lạt và chút đường bột đến khi sánh mịn dẻo thơm óng ả.',
          durationMinutes: 10,
        ),
        const CookingStep(
          stepNumber: 3,
          title: 'Rưới sốt ngập bánh & Phủ chà bông',
          description:
              'Rưới lớp sốt dầu trứng và sốt phô mai tràn mặt bánh bông lan mềm xốp, xếp lòng đỏ trứng muối và rắc ngập tràn chà bông tơi xốp.',
          tip:
              'Cốt bánh bông lan chiffon mềm ẩm kết hợp cùng vị mặn béo của trứng muối và sốt phô mai tạo nên hương vị bùng nổ.',
          durationMinutes: 20,
        ),
      ],
    ),
  ];
}

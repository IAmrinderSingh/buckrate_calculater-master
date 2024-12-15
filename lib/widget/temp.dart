
Step(
          title: const Text('Select Subcategory'),
          content: Column(
            children: [
              DropdownButton<String>(
                hint: const Text('Select Subcategory'),
                value: selectedSubcategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSubcategory = newValue;
                    selectedOption = null; // Reset option
                    optionsList = subCategories[selectedCategory]!
                        .toList(); // Update options
                  });
                },
                items: selectedCategory != null
                    ? subCategories[selectedCategory]!
                        .map<DropdownMenuItem<String>>((String subcategory) {
                        return DropdownMenuItem<String>(
                          value: subcategory,
                          child: Text(subcategory),
                        );
                      }).toList()
                    : [],
              ),
            ],
          ),
        ),
        Step(
          title: const Text('Select Option'),
          content: Column(
            children: [
              DropdownButton<String>(
                hint: const Text('Select Option'),
                value: selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue;
                  });
                },
                items:
                    optionsList.map<DropdownMenuItem<String>>((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
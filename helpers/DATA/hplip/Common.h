#ifndef _COMMON_H
#define _COMMON_H

#include<iostream>
#include<string>
#include<string.h>
#include<fstream>
#include<unistd.h>
#include<sstream>
#include<vector>
#include<map>
#include<algorithm>
#include<sstream>

using namespace std;


typedef pair <string, string> STRING_STRING_PAIR;

typedef vector<STRING_STRING_PAIR> PAIR_VECTOR;

/** typedef  struct _MODEL_DICT_       */
typedef struct _MODEL_DICT_ MODEL_DICT;

/** typedef  map< string,  MODEL_DICT> */
typedef map< string,  MODEL_DICT> MODEL_DICT_MAP;

/** typedef  vector <string>           */
typedef vector <string> STRING_VECTOR;

/** typedef  map<string, string>       */
typedef map<string, string> STRING_PAIR;

/** @struct _MODEL_DICT_

 *  @brief This structure contains models.dat info
 *  @var _MODEL_DICT_::s_tech_class 
 *  Member 's_tech_class' contains tech_class info

 *  @var _MODEL_DICT_::s_sub_class 
 *  Member 's_sub_class' contains sub_class info

 *  @var _MODEL_DICT_::s_family_class 
 *  Member 's_family_class' contains family_class info

 *  @var _MODEL_DICT_::s_normal_model_name 
 *  Member 's_normal_model_name' contains update model_name info

 *  @var _MODEL_DICT_::s_plugin 
 *  Member 's_plugin' contains plugin info

 *  @var _MODEL_DICT_::s_plugin_reason 
 *  Member 's_plugin_reason' contains plugin-reason info

 *  @var _MODEL_DICT_::model_variants 
 *  Member 'model_variants' contains vector info of model variants

*/
struct _MODEL_DICT_
{
  string s_tech_class;
  string s_sub_class;
  string s_family_class;
  string s_normal_model_name;
  int s_plugin;
  int s_plugin_reason;
  STRING_VECTOR model_variants;

};




#endif

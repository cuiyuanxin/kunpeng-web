<script setup lang="ts">
import { computed, reactive } from 'vue';
import { REG_PWD, REG_USER_NAME } from '@/constants/reg';
import { useAuthStore } from '@/store/modules/auth';
import { useFormRules, useNaiveForm } from '@/hooks/common/form';
import { $t } from '@/locales';

defineOptions({
  name: 'PwdLogin'
});

const authStore = useAuthStore();
const { formRef, validate } = useNaiveForm();

interface FormModel {
  username: string;
  password: string;
  rememberMe: boolean;
}

const model: FormModel = reactive({
  username: 'Kunpeng',
  password: 'Kunpeng123456~',
  rememberMe: false
});

const rules = computed<Partial<Record<keyof FormModel, App.Global.FormRule[]>>>(() => {
  // inside computed to make locale reactive, if not apply i18n, you can define it without computed
  const { createRequiredRule } = useFormRules();

  const patternRules = {
    username: {
      pattern: REG_USER_NAME,
      message: $t('form.login.username.invalid'),
      trigger: 'change'
    },
    password: {
      pattern: REG_PWD,
      message: $t('form.login.pwd.invalid'),
      trigger: 'change'
    }
  } satisfies Record<string, App.Global.FormRule>;

  const formRules = {
    username: [createRequiredRule($t('form.login.username.required')), patternRules.username],
    password: [createRequiredRule($t('form.login.pwd.required')), patternRules.password]
  } satisfies Record<string, App.Global.FormRule[]>;

  return {
    username: formRules.username,
    password: formRules.password
  };
});

async function handleSubmit() {
  // 表单验证
  await validate();
  // 执行登录
  await authStore.login({ username: model.username, password: model.password, rememberMe: model.rememberMe });
}
</script>

<template>
  <NForm ref="formRef" :model="model" :rules="rules" size="large" :show-label="false" @keyup.enter="handleSubmit">
    <NFormItem path="username">
      <NInput v-model:value="model.username" clearable :placeholder="$t('page.login.common.usernamePlaceholder')" />
    </NFormItem>
    <NFormItem path="password">
      <NInput
        v-model:value="model.password"
        type="password"
        show-password-on="click"
        clearable
        :placeholder="$t('page.login.common.passwordPlaceholder')"
      />
    </NFormItem>
    <NSpace vertical :size="24">
      <div class="flex-y-center justify-between">
        <NCheckbox v-model:checked="model.rememberMe">{{ $t('page.login.pwdLogin.rememberMe') }}</NCheckbox>
        <!--
 <NButton quaternary @click="toggleLoginModule('reset-pwd')">
          {{ $t('page.login.pwdLogin.forgetPassword') }}
        </NButton>
-->
      </div>
      <NButton type="primary" size="large" round block :loading="authStore.loginLoading" @click="handleSubmit">
        {{ $t('page.login.common.login') }}
      </NButton>
    </NSpace>
  </NForm>
</template>
